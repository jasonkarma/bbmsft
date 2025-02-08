import SwiftUI
import AVFoundation

@MainActor
final class FaceCaptureViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isProcessing = false
    @Published private(set) var analysisResult: SkinAnalysisModels.Response?
    @Published private(set) var error: SkinAnalysisError?
    @Published private(set) var showCameraAccessAlert = false
    
    // MARK: - Properties
    let session = AVCaptureSession()
    private var device: AVCaptureDevice?
    private var output: AVCapturePhotoOutput?
    private let skinAnalysisService: SkinAnalysisServiceProtocol
    private var captureCompletion: ((Result<SkinAnalysisModels.Response, SkinAnalysisError>) -> Void)?
    
    // MARK: - Initialization
    override init() {
        self.skinAnalysisService = SkinAnalysisServiceImpl()
        super.init()
        checkCameraAuthorization()
    }
    
    // MARK: - Camera Setup
    func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                await MainActor.run {
                    if granted {
                        self.setupCamera()
                    } else {
                        self.showCameraAccessAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showCameraAccessAlert = true
        @unknown default:
            break
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        
        self.device = device
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            let output = AVCapturePhotoOutput()
            
            if session.canAddInput(input) && session.canAddOutput(output) {
                session.beginConfiguration()
                session.addInput(input)
                session.addOutput(output)
                session.commitConfiguration()
                self.output = output
            }
            
            Task.detached {
                await self.session.startRunning()
            }
        } catch {
            print("Failed to setup camera: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Camera Controls
    func captureAndAnalyze() async throws -> SkinAnalysisModels.Response {
        return try await withCheckedThrowingContinuation { continuation in
            guard let output = output else {
                continuation.resume(throwing: SkinAnalysisError.cameraSetupError)
                return
            }
            
            isProcessing = true
            let settings = AVCapturePhotoSettings()
            captureCompletion = { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            output.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func zoomIn() {
        adjustZoom(factor: 1.5)
    }
    
    func zoomOut() {
        adjustZoom(factor: 0.67)
    }
    
    private func adjustZoom(factor: CGFloat) {
        guard let device = device else { return }
        
        do {
            try device.lockForConfiguration()
            let newZoom = max(1.0, min(device.videoZoomFactor * factor, device.maxAvailableVideoZoomFactor))
            device.videoZoomFactor = newZoom
            device.unlockForConfiguration()
        } catch {
            print("Failed to adjust zoom: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Settings
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension FaceCaptureViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        Task { @MainActor in
            if let error = error {
                captureCompletion?(.failure(.cameraError(error)))
                isProcessing = false
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                captureCompletion?(.failure(.imageProcessingError))
                isProcessing = false
                return
            }
            
            do {
                let result = try await skinAnalysisService.analyzeSkin(image: image)
                captureCompletion?(.success(result))
            } catch let error as SkinAnalysisError {
                captureCompletion?(.failure(error))
            } catch {
                captureCompletion?(.failure(.unknown(error)))
            }
            isProcessing = false
        }
    }
}
