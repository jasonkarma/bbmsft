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
    
    // MARK: - Properties
    public private(set) var session: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var onCapture: ((UIImage) -> Void)?
    
    // MARK: - Initialization
    public override init() {
        super.init()
        Task {
            try? await setupCamera()
        }
    }
    
    // MARK: - Public Methods
    public func setOnCapture(_ callback: @escaping (UIImage) -> Void) {
        self.onCapture = callback
    }
    
    public func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Private Methods
    private func setupCamera() async throws {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        // Get front camera
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw CameraError.setupError
        }
        
        // Configure input
        let input = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // Configure output
        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            self.photoOutput = photoOutput
        }
        
        self.session = session
        session.startRunning()
        self.showCamera = true
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
            if let error = error {
                print("Photo capture error: \(error)")
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                return
            }
            
            self.capturedImage = image
            self.onCapture?(image)
        }
    }
}

// MARK: - Types
extension CameraScannerViewModel {
    public enum CameraError: Error {
        case setupError
        case captureError
        case permissionDenied
    }
}

#endif
