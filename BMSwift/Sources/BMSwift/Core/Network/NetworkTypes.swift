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
}

// MARK: - API Endpoint Protocol
public protocol BMNetworkAPIEndpoint {
    associatedtype RequestType: Codable
    associatedtype ResponseType: Codable
    
    var path: String { get }
    var method: BMNetwork.HTTPMethod { get }
    var requiresAuth: Bool { get }
    var headers: [String: String] { get }
}

// MARK: - Default Implementation
public extension BMNetworkAPIEndpoint {
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    var requiresAuth: Bool { false }
}

// MARK: - API Request
public struct BMNetworkAPIRequest<Endpoint: BMNetworkAPIEndpoint> {
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
public enum BMNetworkAPIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(String)
    case unauthorized
    case notFound
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Resource not found"
        }
    }
}
