#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import AVFoundation
import UIKit
import Vision

/// ViewModel for handling camera capture functionality in the skin analysis feature.
/// Manages camera permissions, setup, and photo capture.
@available(iOS 13.0, *)
@MainActor
public final class CameraScannerViewModel: NSObject, ObservableObject {
    // MARK: - Types
    
    /// Represents the current state of the camera scanner
    public enum ViewState: Equatable {
        case initial
        case requestingPermission
        case ready
        case capturing
        case error(SkinAnalysisError)
        
        var isCapturing: Bool {
            if case .capturing = self { return true }
            return false
        }
        
        var error: SkinAnalysisError? {
            if case .error(let error) = self { return error }
            return nil
        }
    }
    
    // MARK: - Published Properties
    @Published public private(set) var state: ViewState = .initial
    @Published public private(set) var capturedImage: UIImage?
    @Published public private(set) var showCamera: Bool = false
    @Published public private(set) var detectedFaceRect: CGRect?
    @Published public private(set) var faceDetectionStatus: String?
    @Published public private(set) var isFacePositionValid = false
    
    // MARK: - Properties
    public private(set) var session: AVCaptureSession?
    private var output: AVCapturePhotoOutput?
    private var onCapture: ((UIImage) -> Void)?
    
    // Face detection
    private let minFaceRatio: CGFloat = 0.4
    private let maxFaceRatio: CGFloat = 0.8
    private let optimalFaceRatio: CGFloat = 0.6
    private let faceDetectionQueue = DispatchQueue(label: "com.bmswift.facedetection")
    
    // MARK: - Initialization
    public override init() {
        super.init()
        Task {
            await checkCameraAuthorization()
        }
    }
    
    private func checkCameraAuthorization() async {
        state = .requestingPermission
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            await setupCamera()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                await setupCamera()
            } else {
                state = .error(.permissionDenied)
            }
        case .denied, .restricted:
            state = .error(.permissionDenied)
        @unknown default:
            state = .error(.permissionDenied)
        }
    }
    
    private nonisolated func setupCameraSession() async -> AVCaptureSession? {
        let session = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return nil
        }
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        // Add video output for face detection
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: faceDetectionQueue)
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
        return session
    }
    
    private func setupCamera() async {
        guard let session = await setupCameraSession() else {
            state = .error(.cameraSetupError)
            return
        }
        
        self.session = session
        self.output = session.outputs.first { $0 is AVCapturePhotoOutput } as? AVCapturePhotoOutput
        
        // Start session on background thread
        Task.detached {
            session.startRunning()
        }
        
        showCamera = true
        state = .ready
    }
    
    // MARK: - Public Methods
    
    /// Sets the callback for when a photo is captured
    public func setOnCapture(_ callback: @escaping (UIImage) -> Void) {
        self.onCapture = callback
    }
    
    /// Opens the app settings
    public func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        UIApplication.shared.open(settingsUrl)
    }
    
    /// Starts camera setup and authorization check
    public func start() {
        Task { @MainActor in
            await checkCameraAuthorization()
        }
    }
    
    public func capturePhoto() {
        guard let output = output else { return }
        state = .capturing
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Private Methods
    nonisolated private func detectFace(in image: CVImageBuffer) {
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let error = error {
                    self.faceDetectionStatus = "Error detecting face: \(error.localizedDescription)"
                    self.detectedFaceRect = nil
                    self.isFacePositionValid = false
                    return
                }
                
                guard let observations = request.results as? [VNFaceObservation] else {
                    self.faceDetectionStatus = "Position your face in the frame"
                    self.detectedFaceRect = nil
                    self.isFacePositionValid = false
                    return
                }
                
                if observations.isEmpty {
                    self.faceDetectionStatus = "No face detected"
                    self.detectedFaceRect = nil
                    self.isFacePositionValid = false
                    return
                }
                
                if observations.count > 1 {
                    self.faceDetectionStatus = "Multiple faces detected"
                    self.detectedFaceRect = nil
                    self.isFacePositionValid = false
                    return
                }
                
                let faceObservation = observations[0]
                let faceRect = faceObservation.boundingBox
                
                // Convert normalized coordinates to view coordinates
                let viewRect = CGRect(
                    x: faceRect.origin.x,
                    y: 1 - faceRect.origin.y - faceRect.height,
                    width: faceRect.width,
                    height: faceRect.height
                )
                
                self.detectedFaceRect = viewRect
                
                // Validate face position and size
                let faceRatio = faceRect.height
                if faceRatio > self.maxFaceRatio {
                    self.faceDetectionStatus = "Move back"
                    self.isFacePositionValid = false
                } else if faceRatio < self.minFaceRatio {
                    self.faceDetectionStatus = "Move closer"
                    self.isFacePositionValid = false
                } else {
                    let centerX = faceRect.midX
                    let centerY = faceRect.midY
                    let iscentered = (0.4...0.6).contains(centerX) && (0.4...0.6).contains(centerY)
                    
                    if !iscentered {
                        self.faceDetectionStatus = "Center your face in the frame"
                        self.isFacePositionValid = false
                    } else {
                        self.faceDetectionStatus = "Perfect! Hold still"
                        self.isFacePositionValid = true
                    }
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .up, options: [:])
        try? handler.perform([request])
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraScannerViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        Task { @MainActor in
            if let error = error {
                self.state = .error(.cameraError(error))
                print("Error capturing photo: \(error)")
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                self.state = .error(.imageProcessingError)
                return
            }
            
            self.capturedImage = image
            self.onCapture?(image)
            self.state = .ready
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraScannerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        detectFace(in: imageBuffer)
    }
}

#endif
