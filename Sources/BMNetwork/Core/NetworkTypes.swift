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
    
    /// API environment
    public enum APIEnvironment {
        case encyclopedia
        // Add more environments as needed
    }
    
    /// Empty request type for endpoints that don't need request body
    public struct EmptyRequest: Codable {
        public init() {}
    }
    
    /// Empty response type for endpoints that don't return data
    public struct EmptyResponse: Codable {
        public init() {}
    }
    
    /// Error response from server
    public struct ErrorResponse: Codable {
        public let error: String
        
        public init(error: String) {
            self.error = error
        }
    }
    
    /// API error types
    public enum APIError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
        case unauthorized
        case notFound
        case serverError(String)
        case networkError(Error)
        
        public var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .invalidData:
                return "Invalid data received"
            case .unauthorized:
                return "Unauthorized access"
            case .notFound:
                return "Resource not found"
            case .serverError(let message):
                return "Server error: \(message)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - API Endpoint Protocol
    /// Represents an API endpoint
    public protocol APIEndpoint {
        /// The request type for this endpoint
        associatedtype RequestType: Encodable
        /// The response type for this endpoint
        associatedtype ResponseType: Decodable
        
        /// The path component of the URL
        var path: String { get }
        /// The HTTP method to use
        var method: HTTPMethod { get }
        /// Whether this endpoint requires authentication
        var requiresAuth: Bool { get }
        /// Custom headers for the endpoint
        var headers: [String: String] { get }
        /// Base URL for external APIs. If nil, uses the default base URL
        var baseURL: URL? { get }
        /// Whether this endpoint is from an external API
        var isExternalAPI: Bool { get }
    }
    
    /// Request wrapper for an API endpoint
    public struct APIRequest<E: APIEndpoint> {
        /// The endpoint being requested
        public let endpoint: E
        
        /// Optional request body
        public let body: E.RequestType?
        
        /// Authentication token if needed
        public let authToken: String?
        
        /// Query parameters
        public let queryItems: [URLQueryItem]?
        
        public init(endpoint: E, 
                   body: E.RequestType? = nil,
                   authToken: String? = nil,
                   queryItems: [URLQueryItem]? = nil) {
            self.endpoint = endpoint
            self.body = body
            self.authToken = authToken
            self.queryItems = queryItems
        }
    }
}

/// Default implementation for common properties
public extension BMNetwork.APIEndpoint {
    var headers: [String: String] { ["Content-Type": "application/json"] }
    var requiresAuth: Bool { true }
    var baseURL: URL? { nil }
    var isExternalAPI: Bool { false }
}
