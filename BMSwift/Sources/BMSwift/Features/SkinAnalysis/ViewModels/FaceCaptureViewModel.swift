#if canImport(UIKit) && os(iOS)
import Foundation
import AVFoundation
import UIKit

@MainActor
public final class FaceCaptureViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var isProcessing = false
    @Published public private(set) var error: Error?
    @Published public private(set) var isSetup = false
    @Published public private(set) var zoomFactor: CGFloat = 1.0
    @Published public var session = AVCaptureSession()
    
    // MARK: - Private Properties
    private var device: AVCaptureDevice?
    private var output: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var continuation: CheckedContinuation<UIImage, Error>?
    
    // MARK: - Initialization
    public override init() {
        super.init()
        setupSession()
    }
    
    // MARK: - Public Methods
    public func startSession() {
        guard !session.isRunning else { return }
        session.startRunning()
    }
    
    public func stopSession() {
        guard session.isRunning else { return }
        session.stopRunning()
    }
    
    public func capturePhoto() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            guard let output = output else {
                continuation.resume(throwing: SkinAnalysisError.cameraSetupError)
                return
            }
            
            isProcessing = true
            self.continuation = continuation
            
            let settings = AVCapturePhotoSettings()
            output.capturePhoto(with: settings, delegate: self)
        }
    }
    
    public func zoomIn() {
        adjustZoom(factor: 1.5)
    }
    
    public func zoomOut() {
        adjustZoom(factor: 0.5)
    }
    
    public func resetZoom() {
        adjustZoom(factor: 1.0)
    }
    
    // MARK: - Private Methods
    private func setupSession() {
        session.beginConfiguration()
        
        // Add video input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            error = SkinAnalysisError.cameraSetupError
            return
        }
        self.device = device
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            error = SkinAnalysisError.cameraSetupError
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // Add photo output
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            self.output = output
        }
        
        session.commitConfiguration()
        isSetup = true
    }
    
    private func adjustZoom(factor: CGFloat) {
        guard let device = device else { return }
        
        do {
            try device.lockForConfiguration()
            let newFactor = max(1.0, min(factor * zoomFactor, device.activeFormat.videoMaxZoomFactor))
            device.videoZoomFactor = newFactor
            zoomFactor = newFactor
            device.unlockForConfiguration()
        } catch {
            print("Could not lock device for configuration: \(error)")
        }
    }
    
    nonisolated private func handleCapturedPhoto(_ photo: AVCapturePhoto, error: Error?) {
        Task { @MainActor in
            defer { 
                self.isProcessing = false
                self.continuation = nil
            }
            
            if let error = error {
                self.continuation?.resume(throwing: SkinAnalysisError.cameraError(error))
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                self.continuation?.resume(throwing: SkinAnalysisError.imageProcessingError)
                return
            }
            
            self.continuation?.resume(returning: image)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension FaceCaptureViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated public func photoOutput(_ output: AVCapturePhotoOutput, 
                                      didFinishProcessingPhoto photo: AVCapturePhoto, 
                                      error: Error?) {
        handleCapturedPhoto(photo, error: error)
    }
}
#endif
