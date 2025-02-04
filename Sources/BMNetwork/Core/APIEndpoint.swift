import Foundation

/// Protocol for defining API endpoints
public protocol APIEndpoint {
    /// The type of request body
    associatedtype RequestType: Encodable
    /// The type of response body
    associatedtype ResponseType: Decodable
    
    /// The base URL for this endpoint
    var baseURL: URL { get }
    /// The path component of the URL
    var path: String { get }
    /// The HTTP method to use
    var method: HTTPMethod { get }
    /// Whether this endpoint requires authentication
    var requiresAuth: Bool { get }
    /// Additional headers specific to this endpoint
    var headers: [String: String] { get }
    
    /// The feature namespace this endpoint belongs to
    /// This helps prevent mixing of concerns between features
    static var featureNamespace: String { get }
}

/// Default implementation for APIEndpoint
public extension APIEndpoint {
    var headers: [String: String] { [:] }
}

/// HTTP methods supported by the API
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
