import Foundation

/// Namespace for network-related types
public enum BMNetwork {
    // MARK: - Configuration
    public struct Configuration {
        /// Base URL for the API endpoints
        public let baseURL: URL
        
        /// Default headers to be included in all requests
        public let defaultHeaders: [String: String]
        
        /// Default timeout interval for requests
        public let timeoutInterval: TimeInterval
        
        /// Default cache policy for requests
        public let cachePolicy: URLRequest.CachePolicy
        
        /// Creates a new Configuration instance
        public init(
            baseURL: URL,
            defaultHeaders: [String: String] = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            timeoutInterval: TimeInterval = 30,
            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
        ) {
            self.baseURL = baseURL
            self.defaultHeaders = defaultHeaders
            self.timeoutInterval = timeoutInterval
            self.cachePolicy = cachePolicy
        }
    }
    
    // MARK: - HTTP Method
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    // MARK: - Network Client Protocol
    public protocol NetworkClientProtocol {
        func send<E: APIEndpoint>(_ request: APIRequest<E>) async throws -> E.ResponseType
    }
    
    // MARK: - Request Encoding Protocols
    
    /// Protocol for endpoints that need custom request body encoding
    public protocol RequestBodyEncodable {
        /// Encode the request body according to the endpoint's requirements
        /// - Parameter request: The request to encode
        /// - Returns: The encoded request body data
        func encodeRequestBody<T: Encodable>(request: T) throws -> Data
    }
    
    /// Protocol for endpoints that need to validate their request body
    public protocol RequestBodyValidatable {
        /// Validate the encoded request body before sending
        /// - Parameters:
        ///   - body: The encoded body data
        ///   - headers: The current request headers
        /// - Throws: APIError if validation fails
        func validateRequestBody(_ body: Data, headers: [String: String]) throws
    }
    
    /// Protocol for endpoints that need to modify headers based on the request body
    public protocol HeadersCustomizable {
        /// Customize headers based on the request body
        /// - Parameter body: The request body to consider
        /// - Returns: Additional headers to apply
        func customizeHeaders(for body: Data) -> [String: String]
    }
    
    public protocol APIEndpoint {
        associatedtype RequestType: Encodable
        associatedtype ResponseType: Decodable
        
        /// Path component of the endpoint URL
        var path: String { get }
        
        /// HTTP method for the request
        var method: HTTPMethod { get }
        
        /// Whether the endpoint requires authentication
        var requiresAuth: Bool { get }
        
        /// Optional base URL override
        var baseURL: URL? { get }
        
        /// Additional headers for the request
        var headers: [String: String] { get }
        
        /// Optional timeout interval override
        var timeoutInterval: TimeInterval? { get }
        
        /// Optional cache policy override
        var cachePolicy: URLRequest.CachePolicy? { get }
        
        /// Optional query items
        var queryItems: [URLQueryItem]? { get }
    }
    
    // MARK: - API Request
    public struct APIRequest<E: APIEndpoint> {
        public let endpoint: E
        public let body: E.RequestType?
        public let authToken: String?
        public let queryItems: [URLQueryItem]?
        
        public init(
            endpoint: E,
            body: E.RequestType? = nil,
            authToken: String? = nil,
            queryItems: [URLQueryItem]? = nil
        ) {
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
        case encodingError(String)
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid server response"
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
            case .encodingError(let message):
                return "Failed to encode request: \(message)"
            }
        }
    }
    
    // MARK: - Empty Types
    public struct EmptyRequest: Codable {
        public init() {}
    }
    
    public struct EmptyResponse: Codable {
        public init() {}
    }
}

// MARK: - Default Implementations
public extension BMNetwork.APIEndpoint {
    var baseURL: URL? { nil }
    var headers: [String: String] { ["Content-Type": "application/json"] }
    var timeoutInterval: TimeInterval? { nil }
    var cachePolicy: URLRequest.CachePolicy? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var requiresAuth: Bool { false }
    
    func encode(_ request: RequestType) throws -> Data? {
        try JSONEncoder().encode(request)
    }
}
