import Foundation
#if canImport(UIKit)
import UIKit

extension BMNetwork {
    // MARK: - Image Uploader Protocol
    public protocol ImageUploaderProtocol {
        func uploadImage(_ image: UIImage) async throws -> ImgurResponse
    }
    
    // MARK: - Image Uploader Implementation
    public final class ImageUploader: ImageUploaderProtocol {
        // MARK: - Properties
        private let configuration: Configuration
        private let session: URLSession
        private let tokenManager: BMNetwork.ImgurTokenManager
        
        // MARK: - Initialization
        public init(
            configuration: Configuration = Configuration(
                baseURL: URL(string: "https://api.imgur.com/3")!,
                defaultHeaders: [:]  // Headers will be set by token manager
            ),
            session: URLSession = .shared,
            tokenManager: BMNetwork.ImgurTokenManager = BMNetwork.ImgurTokenManager()
        ) {
            self.configuration = configuration
            self.session = session
            self.tokenManager = tokenManager
        }
        
        // MARK: - Upload Methods
        public func uploadImage(_ image: UIImage) async throws -> ImgurResponse {
            // Convert image to data with compression
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw ImageUploadError.imageCompressionFailed
            }
            
            // Validate image data size (max 10MB)
            guard imageData.count <= 10 * 1024 * 1024 else {
                throw ImageUploadError.imageTooLarge
            }
            
            // Create multipart form data
            let boundary = "Boundary-\(UUID().uuidString)"
            var request = URLRequest(url: configuration.baseURL.appendingPathComponent("image"))
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            // Get Imgur token and set authorization header
            let token = try await tokenManager.getToken()
            request.setValue("Client-ID \(token)", forHTTPHeaderField: "Authorization")
            
            // Create body
            var body = Data()
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
            body.append("--\(boundary)--\r\n")
            
            request.httpBody = body
            
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ImageUploadError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw ImageUploadError.serverError("Status code: \(httpResponse.statusCode)")
                }
                
                return try JSONDecoder().decode(ImgurResponse.self, from: data)
            } catch let urlError as URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    throw ImageUploadError.networkError("網路連線中斷")
                case .timedOut:
                    throw ImageUploadError.networkError("網路連線逾時")
                default:
                    throw ImageUploadError.networkError("網路連線錯誤")
                }
            } catch let decodingError as DecodingError {
                throw ImageUploadError.invalidResponse
            }
            

        }
    }
    
    // MARK: - Response Types
    public struct ImgurResponse: Codable {
        public let data: ImageData
        public let success: Bool
        public let status: Int
    }
    
    public struct ImageData: Codable {
        public let id: String
        public let title: String?
        public let description: String?
        public let type: String
        public let link: String?
        public let width: Int
        public let height: Int
        public let size: Int
        public let deletehash: String?
    }
    
    // MARK: - Error Types
    public enum ImageUploadError: LocalizedError {
        case imageCompressionFailed
        case imageTooLarge
        case invalidResponse
        case serverError(String)
        case tokenError(String)
        case networkError(String)
        
        public var errorDescription: String? {
            switch self {
            case .imageCompressionFailed:
                return "無法壓縮圖片"
            case .imageTooLarge:
                return "圖片太大，請選擇較小的圖片"
            case .invalidResponse:
                return "伺服器回應無效"
            case .serverError(let message):
                return "伺服器錯誤: \(message)"
            case .tokenError(let message):
                return "認證錯誤: \(message)"
            case .networkError(let message):
                return message
            }
        }
    }
    
    // MARK: - Token Management
    public protocol ImgurTokenManaging {
        func getToken() async throws -> String
    }
    
    public final class ImgurTokenManager: ImgurTokenManaging {
        private let clientId: String
        
        public init(clientId: String = "YOUR_CLIENT_ID") {
            self.clientId = clientId
        }
        
        public func getToken() async throws -> String {
            // In a real implementation, this would handle token caching and refresh
            // For now, just return the client ID
            return clientId
        }
    }
}

fileprivate extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
#endif
