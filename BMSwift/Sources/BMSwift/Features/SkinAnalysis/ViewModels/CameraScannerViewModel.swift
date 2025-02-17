#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import AVFoundation
import UIKit
import Vision

@MainActor
public final class CameraScannerViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var showCamera = false
    @Published public private(set) var faceDetectionStatus: String?
    @Published public private(set) var capturedImage: UIImage?
    @Published private(set) var canTakePhoto: Bool = false
    
    // MARK: - Properties
    public private(set) var session: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var onCapture: ((UIImage) -> Void)?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let processingQueue = DispatchQueue(label: "com.bmswift.facedetection", qos: .userInitiated)
    
    // Face detection constants
    private let minFaceRatio: CGFloat = 0.1  // Minimum face size relative to image height
    private let maxFaceRatio: CGFloat = 0.8  // Maximum face size relative to image height
    private let maxImageDimension: CGFloat = 4096
    private let minImageDimension: CGFloat = 48
    private let maxFileSize: Int = 2 * 1024 * 1024 // 2MB
    
    // MARK: - Initialization
    public override init() {
        super.init()
        Task {
            await setupCamera()
        }
    }
    
    // MARK: - Public Methods
    public func setOnCapture(_ callback: @escaping (UIImage) -> Void) {
        self.onCapture = callback
    }
    
    public func capturePhoto() {
        guard let photoOutput = photoOutput, canTakePhoto else { return }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Private Methods
    private func setupCamera() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status != .authorized {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if !granted {
                handleCameraError(.permissionDenied)
                return
            }
        }
        
        do {
            let session = AVCaptureSession()
            session.sessionPreset = .photo
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                throw CameraError.setupError
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            let photoOutput = AVCapturePhotoOutput()
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                self.photoOutput = photoOutput
            }
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                self.videoOutput = videoOutput
            }
            
            self.session = session
            
            Task.detached {
                session.startRunning()
            }
            
            self.showCamera = true
            self.faceDetectionStatus = "請保持臉部在框內"
        } catch {
            handleCameraError(.setupError)
        }
    }
    
    private func processImage(_ image: UIImage) async throws -> UIImage {
        // First fix the image orientation to .up
        let processedImage = image.fixOrientation()
        
        // Create a square crop from the center
        let squareImage = processedImage.centerCrop()
        
        // Resize if needed
        let finalImage = squareImage.resizeIfNeeded(maxDimension: maxImageDimension)
        
        // Compress if needed
        var quality: CGFloat = 0.9
        while let data = finalImage.jpegData(compressionQuality: quality), data.count > maxFileSize {
            quality -= 0.1
            if quality < 0.1 {
                throw CameraError.imageProcessingError
            }
        }
        
        return finalImage
    }
    
    private func updateFaceDetectionStatus(observations: [VNFaceObservation]? = nil, faceHeight: CGFloat? = nil) {
        guard let observations = observations else {
            handleFaceDetectionError(.noFaceDetected)
            return
        }
        
        if observations.count > 1 {
            handleFaceDetectionError(.multipleFacesDetected)
            return
        }
        
        if observations.isEmpty {
            handleFaceDetectionError(.noFaceDetected)
            return
        }
        
        if let faceHeight = faceHeight {
            if faceHeight < self.minFaceRatio {
                handleFaceDetectionError(.faceTooFar)
            } else if faceHeight > self.maxFaceRatio {
                handleFaceDetectionError(.faceTooClose)
            } else {
                self.faceDetectionStatus = "完美！可以拍照了"
                self.canTakePhoto = true
            }
        }
    }
    
    private func handleCameraError(_ error: CameraError) {
        self.faceDetectionStatus = error.localizedDescription
        self.canTakePhoto = false
    }
    
    private func handleFaceDetectionError(_ error: FaceDetectionError) {
        self.faceDetectionStatus = error.localizedDescription
        self.canTakePhoto = false
    }
    
    nonisolated private func detectFace(in image: CVPixelBuffer) {
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if error != nil {
                    self.handleFaceDetectionError(.detectionFailed)
                    return
                }
                
                let observations = request.results as? [VNFaceObservation]
                if let face = observations?.first {
                    self.updateFaceDetectionStatus(observations: observations, faceHeight: face.boundingBox.height)
                } else {
                    self.updateFaceDetectionStatus(observations: observations)
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .up, options: [:])
        try? handler.perform([request])
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraScannerViewModel: AVCapturePhotoCaptureDelegate {
    public nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        Task { @MainActor in
            if error != nil {
                handleCameraError(.captureError)
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                handleCameraError(.imageProcessingError)
                return
            }
            
            do {
                let processedImage = try await processImage(image)
                self.capturedImage = processedImage
                self.onCapture?(processedImage)
            } catch {
                handleCameraError(.imageProcessingError)
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraScannerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    public nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        detectFace(in: pixelBuffer)
    }
}

// MARK: - Error Types
extension CameraScannerViewModel {
    public enum CameraError: LocalizedError {
        case setupError
        case captureError
        case permissionDenied
        case imageProcessingError
        
        public var errorDescription: String? {
            switch self {
            case .setupError:
                return "相機設置失敗"
            case .captureError:
                return "拍照失敗"
            case .permissionDenied:
                return "需要相機權限"
            case .imageProcessingError:
                return "照片處理失敗"
            }
        }
    }
    
    public enum FaceDetectionError: LocalizedError {
        case detectionFailed
        case noFaceDetected
        case multipleFacesDetected
        case faceTooClose
        case faceTooFar
        
        public var errorDescription: String? {
            switch self {
            case .detectionFailed:
                return "人臉檢測失敗"
            case .noFaceDetected:
                return "未檢測到人臉"
            case .multipleFacesDetected:
                return "請確保畫面中只有一張臉"
            case .faceTooClose:
                return "請往後一點"
            case .faceTooFar:
                return "請靠近一點"
            }
        }
    }
}

// MARK: - UIImage Extensions
private extension UIImage {
    func fixOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
    
    func centerCrop() -> UIImage {
        let shortestSide = min(size.width, size.height)
        let xOffset = (size.width - shortestSide) / 2
        let yOffset = (size.height - shortestSide) / 2
        
        let cropRect = CGRect(x: xOffset, y: yOffset, width: shortestSide, height: shortestSide)
        guard let cgImage = cgImage?.cropping(to: cropRect) else { return self }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
    
    func resizeIfNeeded(maxDimension: CGFloat) -> UIImage {
        guard size.width > maxDimension || size.height > maxDimension else { return self }
        
        let scale = maxDimension / max(size.width, size.height)
        let newWidth = size.width * scale
        let newHeight = size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? self
    }
}

#endif
