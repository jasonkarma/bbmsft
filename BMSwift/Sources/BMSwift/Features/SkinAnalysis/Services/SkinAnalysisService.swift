#if canImport(UIKit) && os(iOS)
import Foundation
import UIKit

public protocol SkinAnalysisServiceProtocol {
    func analyzeSkin(image: UIImage) async throws -> SkinAnalysisResponse
}

public final class SkinAnalysisServiceImpl: SkinAnalysisServiceProtocol {
    private let client: BMNetwork.NetworkClient
    private let imageUploader: BMNetwork.ImageUploaderProtocol
    
    public init(
        client: BMNetwork.NetworkClient = .shared,
        imageUploader: BMNetwork.ImageUploaderProtocol = BMNetwork.ImageUploader()
    ) {
        self.client = client
        self.imageUploader = imageUploader
    }
    
    public func analyzeSkin(image: UIImage) async throws -> SkinAnalysisResponse {
        // Step 1: Upload image to Imgur
        let uploadResponse = try await imageUploader.uploadImage(image)
        guard let imageUrl = uploadResponse.data.link else {
            throw SkinAnalysisError.imageUploadFailed
        }
        
        // Step 2: Send image URL to RapidAPI for analysis
        let endpoint = RapidAPI.Endpoint(imageUrl: imageUrl)
        let request = BMNetwork.APIRequest(
            endpoint: endpoint,
            body: RapidAPI.AnalyzeRequest(imageUrl: imageUrl)
        )
        
        do {
            let response: RapidAPI.Response = try await client.send(request)
            return SkinAnalysisResponse(from: response)
        } catch let error as BMNetwork.APIError {
            switch error {
            case .invalidResponse, .decodingError:
                throw SkinAnalysisError.invalidResponse
            case .unauthorized:
                throw SkinAnalysisError.requestCreationFailed
            default:
                throw SkinAnalysisError.analyzeFailed
            }
        } catch {
            throw SkinAnalysisError.analyzeFailed
        }
    }
}

public enum SkinAnalysisError: LocalizedError {
    case imageCompressionFailed
    case imageUploadFailed
    case analyzeFailed
    case invalidResponse
    case requestCreationFailed
    
    public var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "無法壓縮圖片以進行分析"
        case .imageUploadFailed:
            return "圖片上傳失敗，請稍後再試"
        case .analyzeFailed:
            return "皮膚分析失敗，請稍後再試"
        case .invalidResponse:
            return "伺服器回應無效，請稍後再試"
        case .requestCreationFailed:
            return "建立請求失敗，請稍後再試"
        }
    }
}

#if DEBUG
extension SkinAnalysisServiceImpl {
    public func mockAnalyzeSkin() async throws -> SkinAnalysisResponse {
        return .preview
    }
}
#endif
#endif
