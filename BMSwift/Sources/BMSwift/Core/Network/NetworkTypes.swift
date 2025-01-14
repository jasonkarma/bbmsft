import Foundation

/// Namespace for network-related types
public enum BMNetwork {
    // MARK: - HTTP Method
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    // MARK: - API Endpoint Protocol
    public protocol APIEndpoint {
        associatedtype RequestType: Encodable
        associatedtype ResponseType: Decodable
        
        var path: String { get }
        var method: HTTPMethod { get }
        var requiresAuth: Bool { get }
        var headers: [String: String] { get }
    }
    
    // MARK: - Empty Response
    public struct EmptyResponse: Codable {}
    
    // MARK: - API Request
    public struct APIRequest<Endpoint: APIEndpoint> {
        public let endpoint: Endpoint
        public let body: Endpoint.RequestType?
        public let authToken: String?
        public let queryItems: [URLQueryItem]?
        
        public init(endpoint: Endpoint, 
                   body: Endpoint.RequestType? = nil,
                   authToken: String? = nil,
                   queryItems: [URLQueryItem]? = nil) {
            self.endpoint = endpoint
            self.body = body
            self.authToken = authToken
            self.queryItems = queryItems
        }
    }
    
    // MARK: - API Error
    public enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case unauthorized
        case notFound
        case serverError(String)
        case networkError(Error)
        case decodingError(Error)
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .unauthorized:
                return "Unauthorized access"
            case .notFound:
                return "Resource not found"
            case .serverError(let message):
                return "Server error: \(message)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Default Implementation
public extension BMNetwork.APIEndpoint {
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    var requiresAuth: Bool { false }
}
