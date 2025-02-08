#if canImport(UIKit) && os(iOS)
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

/// ViewModel for the skin analysis feature that manages the analysis state and user interactions
@available(iOS 16.0, *)
@MainActor
public final class SkinAnalysisViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var selectedPhotoItem: PhotosPickerItem?
    @Published public var selectedImage: UIImage?
    @Published public private(set) var error: Error?
    @Published public private(set) var isLoading = false
    @Published public private(set) var analysisResult: SkinAnalysisModels.Response?
    
    // MARK: - Dependencies
    private let skinAnalysisService: SkinAnalysisServiceProtocol
    
    // MARK: - Initialization
    public init(skinAnalysisService: SkinAnalysisServiceProtocol = SkinAnalysisServiceImpl(client: BMNetwork.NetworkClient.shared)) {
        self.skinAnalysisService = skinAnalysisService
    }
    
    // MARK: - Public Methods
    /// Clears any error state and returns to idle
    public func clearError() {
        error = nil
    }
    
    /// Analyzes the provided image using the skin analysis service
    /// - Parameter image: The image to analyze
    public func analyzeSkin(image: UIImage?) async {
        guard let image = image else {
            error = BMSwift.SkinAnalysisError.invalidImage
            return
        }
        
        isLoading = true
        error = nil
        analysisResult = nil
        
        do {
            analysisResult = try await skinAnalysisService.analyzeSkin(image: image)
        } catch let error as BMSwift.SkinAnalysisError {
            self.error = error
        } catch {
            self.error = BMSwift.SkinAnalysisError.networkError(error)
        }
        
        isLoading = false
    }
    
    func updateFromCamera(result: SkinAnalysisModels.Response?, error: BMSwift.SkinAnalysisError?) {
        self.analysisResult = result
        self.error = error
    }
    
    /// Resets the view state to idle and clears any selected image or analysis results
    public func reset() {
        isLoading = false
        selectedImage = nil
        selectedPhotoItem = nil
        analysisResult = nil
        error = nil
    }
    
    // MARK: - Private Methods
    private func handleSelectedPhotoItem() {
        guard let photoItem = selectedPhotoItem else { return }
        
        Task {
            do {
                if let data = try await photoItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    await analyzeSkin(image: image)
                }
            } catch {
                self.error = BMSwift.SkinAnalysisError.imageProcessingError
            }
        }
    }
}

// MARK: - Preview Support
#if DEBUG
extension SkinAnalysisViewModel {
    /// Creates a preview instance of the view model with mock data
    public static func preview() -> SkinAnalysisViewModel {
        let viewModel = SkinAnalysisViewModel()
        if let mockImage = UIImage(systemName: "person.circle") {
            viewModel.selectedImage = mockImage
            viewModel.analysisResult = .preview
        }
        return viewModel
    }
}
#endif
#endif