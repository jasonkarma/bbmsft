#if canImport(UIKit) && os(iOS)
import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
@MainActor
public final class SkinAnalysisViewModel: ObservableObject {
    @Published public var selectedImage: UIImage?
    @Published public var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            if let photoItem = selectedPhotoItem {
                loadImage(from: photoItem)
            }
        }
    }
    
    private func loadImage(from photoItem: PhotosPickerItem) {
        Task {
            do {
                // Load the image data
                let imageData = try await photoItem.loadTransferable(type: Data.self)
                guard let imageData = imageData else {
                    throw SkinAnalysisError.imageCompressionFailed
                }
                
                // Check file size (3MB limit)
                guard imageData.count <= 3 * 1024 * 1024 else {
                    throw SkinAnalysisError.imageTooLarge
                }
                
                // Create UIImage
                guard let image = UIImage(data: imageData) else {
                    throw SkinAnalysisError.imageCompressionFailed
                }
                
                // Check dimensions
                let size = image.size
                guard size.width >= 500 && size.width <= 2000 &&
                      size.height >= 500 && size.height <= 2000 else {
                    throw SkinAnalysisError.invalidImageDimensions
                }
                
                await MainActor.run {
                    self.selectedImage = image
                    self.selectedPhotoItem = nil
                    self.error = nil
                    self.isAnalyzing = true
                }
                
                // Start analysis
                do {
                    let result = try await service.analyzeSkin(image: image)
                    await MainActor.run {
                        self.analysisResult = result
                        self.isAnalyzing = false
                    }
                } catch {
                    await MainActor.run {
                        self.error = error as? SkinAnalysisError ?? .analyzeFailed
                        self.isAnalyzing = false
                    }
                }
            } catch {
                print("Error loading image: \(error)")
                await MainActor.run {
                    self.error = error as? SkinAnalysisError ?? .imageCompressionFailed
                    self.selectedPhotoItem = nil
                    self.selectedImage = nil
                }
            }
        }
    }
    
    private func processLoadedImage(_ image: UIImage) async {
        do {
            // Check image size before proceeding
            guard let imageData = image.jpegData(compressionQuality: 0.8),
                  imageData.count <= 10 * 1024 * 1024 else {
                throw BMNetwork.ImageUploadError.imageTooLarge
            }
            
            await MainActor.run {
                self.selectedImage = image
                self.selectedPhotoItem = nil
                self.error = nil
            }
            
            await analyzeSkin(image: image)
        } catch let uploadError as BMNetwork.ImageUploadError {
            print("Image upload error: \(uploadError)")
            await MainActor.run {
                self.error = SkinAnalysisError.imageUploadFailed
                self.selectedPhotoItem = nil
                self.selectedImage = nil
            }
        } catch {
            print("Error processing image: \(error)")
            await MainActor.run {
                self.error = error as? SkinAnalysisError ?? .imageCompressionFailed
                self.selectedPhotoItem = nil
                self.selectedImage = nil
            }
        }
    }
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