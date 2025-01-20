#if canImport(SwiftUI) && os(iOS)
import Foundation
import SwiftUI
import AVFoundation

@available(iOS 13.0, *)
@MainActor
public class SkinAnalysisViewModel: NSObject, ObservableObject {
    @Published public var isAnalyzing = false
    @Published public var results: AnalysisResults?
    @Published public var showError = false
    @Published public var isFlashOn = false
    @Published public var error: Error?
    
    private let service: any SkinAnalysisService
    
    public init(service: some SkinAnalysisService = SkinAnalysisServiceImpl()) {
        self.service = service
        super.init()
    }
    
    public func analyze(image: UIImage) async {
        isAnalyzing = true
        do {
            let result = try await service.analyzeImage(image)
            self.results = result
            self.isAnalyzing = false
        } catch {
            self.error = error
            self.showError = true
            self.isAnalyzing = false
        }
    }
    
    public func toggleFlash() {
        isFlashOn.toggle()
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            try device.lockForConfiguration()
            if device.hasTorch {
                try device.setTorchModeOn(level: 1.0)
            }
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flash: \(error.localizedDescription)")
        }
    }
}
#endif