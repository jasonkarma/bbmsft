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
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw ImageUploadError.imageCompressionFailed
            }
            
            // Create multipart form data
            let boundary = "--Boundary-\(UUID().uuidString)"
            let url = configuration.baseURL.appendingPathComponent("image")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            // Get Imgur token and set authorization header
            let token = try await tokenManager.getToken()
            request.setValue("Client-ID \(token)", forHTTPHeaderField: "Authorization")
            
            // Create body
            var body = Data()
            
            // Add image field
            body.append(boundary.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            
            // Add final boundary
            body.append("\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageUploadError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw ImageUploadError.serverError("Status code: \(httpResponse.statusCode)")
            }
            
            return try JSONDecoder().decode(ImgurResponse.self, from: data)
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
        case invalidResponse
        case serverError(String)
        case tokenError(String)
        case invalidURL
        
        public var errorDescription: String? {
            switch self {
            case .imageCompressionFailed:
                return "Failed to compress image"
            case .invalidResponse:
                return "Invalid response from server"
            case .serverError(let message):
                return "Server error: \(message)"
            case .tokenError(let message):
                return "Token error: \(message)"
            case .invalidURL:
                return "Invalid base URL configuration"
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
