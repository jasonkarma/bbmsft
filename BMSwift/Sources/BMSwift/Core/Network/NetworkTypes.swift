import Foundation

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
    associatedtype RequestType: Codable
    associatedtype ResponseType: Codable
    
    var path: String { get }
    var method: HTTPMethod { get }
    var requiresAuth: Bool { get }
    var headers: [String: String] { get }
}

// MARK: - Default Implementation
public extension APIEndpoint {
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    var requiresAuth: Bool { false }
}

// MARK: - API Request
public struct APIRequest<E: APIEndpoint> {
    public let endpoint: E
    public let body: E.RequestType?
    public let queryItems: [URLQueryItem]?
    public let authToken: String?
    
    public init(endpoint: E, 
                body: E.RequestType? = nil,
                queryItems: [URLQueryItem]? = nil,
                authToken: String? = nil) {
        self.endpoint = endpoint
        self.body = body
        self.queryItems = queryItems
        self.authToken = authToken
    }
}

// MARK: - API Error
public enum APIError: LocalizedError {
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
