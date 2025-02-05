import Foundation

/// Network types and utilities for BMSwift
/// This is the new implementation that will gradually replace the old one
public enum BMNetworkV2 {
    /// Empty request type for endpoints that don't require a body
    public struct EmptyRequest: Codable {
        public init() {}
    }
    
    /// Empty response type for endpoints that don't return data
    public struct EmptyResponse: Codable {
        public init() {}
    }
    // MARK: - HTTP Method
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    // MARK: - API Protocol
    /// Protocol defining an API endpoint
    public protocol APIEndpoint {
        /// Request type for this endpoint
        associatedtype RequestType: Encodable
        /// Response type for this endpoint
        associatedtype ResponseType: Decodable
        
        /// Path component of the URL
        var path: String { get }
        /// HTTP method
        var method: HTTPMethod { get }
        /// Whether authentication is required
        var requiresAuth: Bool { get }
        /// Custom headers
        var headers: [String: String] { get }
    }
    
    // MARK: - Common Types
    /// Response for error messages from server
    public struct ErrorResponse: Codable {
        public let error: String
        public let message: String?
        public let code: Int?
    }
    
    // MARK: - Error Types
    /// Network-related errors
    public enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case invalidData
        case unauthorized
        case notFound
        case serverError(String)
        case networkError(Error)
        case decodingError(Error)
        case tokenExpired
        case tokenMissing
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "無效的網址"
            case .invalidResponse:
                return "伺服器回應無效"
            case .invalidData:
                return "收到無效的資料"
            case .unauthorized:
                return "未經授權的存取"
            case .notFound:
                return "找不到資源"
            case .serverError(let message):
                return "伺服器錯誤: \(message)"
            case .networkError(let error):
                return "網路錯誤: \(error.localizedDescription)"
            case .decodingError(let error):
                return "解碼回應失敗: \(error.localizedDescription)"
            case .tokenExpired:
                return "登入已過期，請重新登入"
            case .tokenMissing:
                return "找不到登入資訊，請重新登入"
            }
        }
    }
}

// MARK: - Default Implementations
public extension BMNetwork.APIEndpoint {
    var headers: [String: String] { ["Content-Type": "application/json"] }
    var requiresAuth: Bool { true }
}
