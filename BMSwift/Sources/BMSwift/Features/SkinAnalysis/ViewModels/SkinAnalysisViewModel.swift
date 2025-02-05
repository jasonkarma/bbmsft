#if canImport(UIKit) && os(iOS)
import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
@MainActor
public final class SkinAnalysisViewModel: ObservableObject {
    @Published public var selectedImage: UIImage?
    @Published public var selectedPhotoItem: PhotosPickerItem?
    @Published public var analysisResult: SkinAnalysisResponse?
    @Published public var isAnalyzing = false
    @Published public var showImagePicker = false
    @Published public var error: Error?
    
    private let service: SkinAnalysisServiceProtocol
    
    public init(service: SkinAnalysisServiceProtocol = SkinAnalysisServiceImpl()) {
        self.service = service
    }
    
    public func analyzeSkin(image: UIImage) async {
        isAnalyzing = true
        error = nil
        analysisResult = nil
        
        do {
            analysisResult = try await service.analyzeSkin(image: image)
        } catch {
            self.error = error
        }
        
        isAnalyzing = false
    }
    
    public func clearError() {
        error = nil
    }
    
    public func clearResult() {
        analysisResult = nil
    }
    
    public func clearSelectedImage() {
        selectedImage = nil
    }
    
    public func reset() {
        selectedImage = nil
        selectedPhotoItem = nil
        analysisResult = nil
        isAnalyzing = false
        error = nil
    }
}

#if DEBUG
extension SkinAnalysisViewModel {
    public static func preview() -> SkinAnalysisViewModel {
        let viewModel = SkinAnalysisViewModel()
        viewModel.analysisResult = .preview
        return viewModel
    }
}
#endif
#endif