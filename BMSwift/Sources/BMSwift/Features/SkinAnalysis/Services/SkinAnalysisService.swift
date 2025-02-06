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
        // Step 1: Prepare image data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw SkinAnalysisError.imageCompressionFailed
        }
        
        // Check size limit (3MB)
        guard imageData.count <= 3 * 1024 * 1024 else {
            throw SkinAnalysisError.imageTooLarge
        }
        
        // Check dimensions
        let size = image.size
        guard size.width >= 500 && size.width <= 2000 &&
              size.height >= 500 && size.height <= 2000 else {
            throw SkinAnalysisError.invalidImageDimensions
        }
        
        // Step 2: Create multipart form data request
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "https://api.example.com/analyze")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add required headers from RapidAPI
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Create body
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        
        // Add optional parameters
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"lang\"\r\n\r\n")
        body.append("zh")
        body.append("\r\n")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"noqueue\"\r\n\r\n")
        body.append("1")
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        // Step 2: Send image URL to RapidAPI for analysis with retry
        let endpoint = RapidAPI.Endpoint(imageUrl: imageUrl)
        let request = BMNetwork.APIRequest(
            endpoint: endpoint,
            body: RapidAPI.AnalyzeRequest(imageUrl: imageUrl)
        )
        
        let maxRetries = 3
        var retryCount = 0
        while retryCount < maxRetries {
            do {
                let response: RapidAPI.Response = try await client.send(request)
                return SkinAnalysisResponse(from: response)
            } catch let error as BMNetwork.APIError {
                switch error {
                case .invalidResponse, .decodingError:
                    throw SkinAnalysisError.invalidResponse
                case .unauthorized:
                    throw SkinAnalysisError.requestCreationFailed
                case .serverError("503"):
                    if retryCount < maxRetries - 1 {
                        retryCount += 1
                        try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * pow(2.0, Double(retryCount)))) // Exponential backoff
                        continue
                    } else {
                        throw SkinAnalysisError.serviceUnavailable
                    }
                default:
                    throw SkinAnalysisError.analyzeFailed
                }
            } catch {
                if retryCount < maxRetries - 1 {
                    retryCount += 1
                    continue
                } else {
                    throw SkinAnalysisError.analyzeFailed
                }
            }
        }
        
        throw SkinAnalysisError.analyzeFailed
    }
}

public enum SkinAnalysisError: LocalizedError {
    case imageCompressionFailed
    case imageUploadFailed
    case analyzeFailed
    case invalidResponse
    case requestCreationFailed
    case serviceUnavailable
    case imageTooLarge
    case invalidImageDimensions
    
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
        case .serviceUnavailable:
            return "分析服務暫時不可用，請稍後再試"
        case .imageTooLarge:
            return "圖片大小超過限制（最大3MB），請選擇較小的圖片"
        case .invalidImageDimensions:
            return "圖片尺寸不符合要求（建議500x500至2000x2000像素）"
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
