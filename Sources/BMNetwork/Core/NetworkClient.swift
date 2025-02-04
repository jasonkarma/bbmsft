import Foundation

/// Network layer namespace
public enum BMNetworkV2 {
    /// Protocol for network client functionality
    public protocol NetworkClientProtocol {
        /// Send a request to an endpoint
        /// - Parameter endpoint: The endpoint to send the request to
        /// - Returns: The decoded response
        func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.ResponseType
        
        /// Send a request with body to an endpoint
        /// - Parameters:
        ///   - endpoint: The endpoint to send the request to
        ///   - body: The request body
        /// - Returns: The decoded response
        func send<E: APIEndpoint>(_ endpoint: E, body: E.RequestType?) async throws -> E.ResponseType
        
        /// Send a request with body and explicit auth token
        /// - Parameters:
        ///   - endpoint: The endpoint to send the request to
        ///   - body: The request body
        ///   - token: Optional authentication token
        /// - Returns: The decoded response
        /// - Note: This method should only be used by the auth service. Other features should use send(_:body:)
        func sendWithExplicitAuth<E: APIEndpoint>(_ endpoint: E, body: E.RequestType?, token: String?) async throws -> E.ResponseType
    }
    
    /// Network client for handling API requests
    /// Configuration for NetworkClient
    public struct Configuration {
        /// Default headers to include in all requests
        public let defaultHeaders: [String: String]
        /// URL session configuration
        public let sessionConfiguration: URLSessionConfiguration
        /// Request interceptors to process requests
        public let requestInterceptors: [RequestInterceptor]
        /// Response interceptors to process responses
        public let responseInterceptors: [ResponseInterceptor]
        
        public init(
            defaultHeaders: [String: String] = [:],
            sessionConfiguration: URLSessionConfiguration = .default,
            requestInterceptors: [RequestInterceptor] = [],
            responseInterceptors: [ResponseInterceptor] = []
        ) {
            self.defaultHeaders = defaultHeaders
            self.sessionConfiguration = sessionConfiguration
            self.requestInterceptors = requestInterceptors
            self.responseInterceptors = responseInterceptors
        }
        
        /// Default configuration
        public static var `default`: Configuration {
            .init(
                requestInterceptors: [AuthRequestInterceptor()],
                responseInterceptors: [ErrorResponseInterceptor()]
            )
        }
    }
    
    public final class NetworkClient: NetworkClientProtocol {
        // MARK: - Properties
        
        public static var shared: NetworkClient = {
            let config = Configuration.production
            return NetworkClient(configuration: config)
        }()
        
        private let configuration: Configuration
        private let session: URLSession
        private let decoder: JSONDecoder
        private let encoder: JSONEncoder
        private let authHandler: AuthenticationHandler
        
        // MARK: - Initialization
        
        public init(
            configuration: Configuration,
            session: URLSession? = nil,
            authHandler: AuthenticationHandler = DefaultAuthenticationHandler()
        ) {
            self.configuration = configuration
            self.session = session ?? URLSession(configuration: configuration.sessionConfiguration)
            
            self.decoder = JSONDecoder()
            self.decoder.keyDecodingStrategy = .convertFromSnakeCase
            self.decoder.dateDecodingStrategy = .iso8601
            
            self.encoder = JSONEncoder()
            self.encoder.keyEncodingStrategy = .convertToSnakeCase
            self.encoder.dateEncodingStrategy = .iso8601
            
            self.authHandler = authHandler
        }
        
        // MARK: - Public Methods
        
        public func send<E: APIEndpoint>(_ endpoint: E) async throws -> E.ResponseType {
            try await send(endpoint, body: nil)
        }
        
        public func send<E: APIEndpoint>(_ endpoint: E, body: E.RequestType?) async throws -> E.ResponseType {
            if endpoint.requiresAuth {
                let token = try await authHandler.getToken()
                return try await sendWithRetry(endpoint, body: body, token: token)
            } else {
                return try await sendRequest(endpoint, body: body, token: nil)
            }
        }
        
        private func sendWithRetry<E: APIEndpoint>(_ endpoint: E, body: E.RequestType?, token: String?, retryCount: Int = 0) async throws -> E.ResponseType {
            do {
                return try await sendRequest(endpoint, body: body, token: token)
            } catch let error {
                // Handle authentication errors
                if retryCount < 1, // Only retry once
                   await authHandler.handleAuthenticationError(error) {
                    // Get fresh token and retry
                    let newToken = try await authHandler.getToken()
                    return try await sendWithRetry(endpoint, body: body, token: newToken, retryCount: retryCount + 1)
                }
                throw error
            }
        }
        
        private func sendRequest<E: APIEndpoint>(_ endpoint: E, body: E.RequestType?, token: String?) async throws -> E.ResponseType {
            // Create URL
            // 1. Create URL
            guard let url = URL(string: endpoint.path, relativeTo: endpoint.baseURL) else {
                throw APIError.invalidURL
            }
            
            // 2. Create request
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            
            // 3. Add headers
            var headers = configuration.defaultHeaders
            headers.merge(endpoint.headers) { _, new in new }
            if endpoint.requiresAuth {
                guard let token = token, !token.isEmpty else {
                    throw APIError.tokenMissing
                }
                headers["Authorization"] = "Bearer \(token)"
            }
            request.allHTTPHeaderFields = headers
            
            // 4. Add body if needed
            if let body = body {
                request.httpBody = try encoder.encode(body)
            }
            
            // 5. Apply request interceptors
            var modifiedRequest = request
            for interceptor in configuration.requestInterceptors {
                modifiedRequest = try await interceptor.intercept(modifiedRequest)
            }
            
            // 6. Send request
            let (data, response) = try await session.data(for: modifiedRequest)
            
            // 7. Apply response interceptors
            var processedData = data
            for interceptor in configuration.responseInterceptors {
                processedData = try await interceptor.intercept(response, data: processedData)
            }
            
            // 8. Decode response
            do {
                return try decoder.decode(E.ResponseType.self, from: processedData)
            } catch {
                throw APIError.decodingError(error)
            }
        }
    }
}
