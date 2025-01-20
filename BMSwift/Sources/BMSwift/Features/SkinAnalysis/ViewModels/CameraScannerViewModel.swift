#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import AVFoundation

@available(iOS 13.0, *)
public class CameraScannerViewModel: NSObject, ObservableObject {
    @Published public var session: AVCaptureSession = AVCaptureSession()
    @Published public var showPermissionAlert: Bool = false
    @Published public var openSettings: Bool = false
    @Published public var photo: UIImage?
    
    private let output = AVCapturePhotoOutput()
    private var onCapture: ((UIImage) -> Void)?
    
    public init(onCapture: @escaping (UIImage) -> Void) {
        self.onCapture = onCapture
        super.init()
        checkPermissions()
    }
    
    public func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async { [weak self] in
                self?.showPermissionAlert = true
            }
        @unknown default:
            break
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    public func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    public func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    deinit {
        session.stopRunning()
    }
}

@available(iOS 13.0, *)
extension CameraScannerViewModel: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.photo = image
            self?.onCapture?(image)
        }
    }
}
#endif
