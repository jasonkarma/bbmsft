#if canImport(SwiftUI) && os(iOS)
import AVFoundation
import UIKit

// MARK: - Camera Service Protocol
public protocol CameraService {
    var session: AVCaptureSession { get }
    var isAuthorized: Bool { get }
    var isFlashAvailable: Bool { get }
    
    func requestAuthorization() async -> Bool
    func startSession() async throws
    func stopSession()
    func setFlashMode(_ mode: AVCaptureDevice.FlashMode)
    func capturePhoto() async throws -> UIImage
}

// MARK: - Camera Service Implementation
public final class CameraServiceImpl: NSObject, CameraService {
    // MARK: - Properties
    private let captureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    private var continuations: [String: CheckedContinuation<UIImage, Error>] = [:]
    private var currentFlashMode: AVCaptureDevice.FlashMode = .off
    
    // MARK: - Public Properties
    public var session: AVCaptureSession {
        captureSession
    }
    
    public var isAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    public var isFlashAvailable: Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }
        return device.hasFlash && device.isFlashAvailable
    }
    
    // MARK: - Initialization
    public override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    public func requestAuthorization() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
    
    public func startSession() async throws {
        guard let device = AVCaptureDevice.default(for: .video) else {
            throw CameraError.deviceNotFound
        }
        
        let input = try AVCaptureDeviceInput(device: device)
        photoOutput = AVCapturePhotoOutput()
        
        captureSession.beginConfiguration()
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        if let photoOutput = photoOutput,
           captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    public func stopSession() {
        captureSession.stopRunning()
    }
    
    public func setFlashMode(_ mode: AVCaptureDevice.FlashMode) {
        currentFlashMode = mode
    }
    
    public func capturePhoto() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            guard let photoOutput = photoOutput else {
                continuation.resume(throwing: CameraError.invalidPhotoOutput)
                return
            }
            
            let settings = AVCapturePhotoSettings()
            settings.flashMode = currentFlashMode
            
            let id = UUID().uuidString
            continuations[id] = continuation
            
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraServiceImpl: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let id = UUID().uuidString
        guard let continuation = continuations.removeValue(forKey: id) else { return }
        
        if let error = error {
            continuation.resume(throwing: error)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            continuation.resume(throwing: CameraError.invalidPhotoData)
            return
        }
        
        continuation.resume(returning: image)
    }
}

// MARK: - Camera Error
public enum CameraError: LocalizedError {
    case deviceNotFound
    case invalidPhotoOutput
    case invalidPhotoData
    
    public var errorDescription: String? {
        switch self {
        case .deviceNotFound:
            return "Camera device not found"
        case .invalidPhotoOutput:
            return "Photo output not available"
        case .invalidPhotoData:
            return "Invalid photo data"
        }
    }
}

#endif
