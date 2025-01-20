#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import AVFoundation
import UIKit

@MainActor
public final class CameraScannerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isAuthorized = false
    @Published private(set) var isFlashOn = false
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private let cameraService: CameraService
    private let onPhotoCapture: (UIImage) -> Void
    
    // MARK: - Public Properties
    var session: AVCaptureSession {
        cameraService.session
    }
    
    var isFlashAvailable: Bool {
        cameraService.isFlashAvailable
    }
    
    // MARK: - Initialization
    public init(
        cameraService: CameraService = CameraServiceImpl(),
        onPhotoCapture: @escaping (UIImage) -> Void
    ) {
        self.cameraService = cameraService
        self.onPhotoCapture = onPhotoCapture
    }
    
    // MARK: - Public Methods
    public func onAppear() {
        Task {
            isAuthorized = await cameraService.requestAuthorization()
            if isAuthorized {
                do {
                    try await cameraService.startSession()
                } catch {
                    self.error = error
                }
            }
        }
    }
    
    public func onDisappear() {
        cameraService.stopSession()
    }
    
    public func toggleFlash() {
        isFlashOn.toggle()
        cameraService.setFlashMode(isFlashOn ? .on : .off)
    }
    
    public func capturePhoto() {
        Task {
            do {
                let photo = try await cameraService.capturePhoto()
                onPhotoCapture(photo)
            } catch {
                self.error = error
            }
        }
    }
}
#endif
