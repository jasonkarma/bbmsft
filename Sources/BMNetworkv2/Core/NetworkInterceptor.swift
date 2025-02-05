import Foundation

extension BMNetworkV2 {
    /// Protocol for intercepting and modifying network requests before they are sent
    public protocol RequestInterceptor {
        /// Intercept and potentially modify a request before it is sent
        /// - Parameter request: The URLRequest to be sent
        /// - Returns: The modified URLRequest
        func intercept(_ request: URLRequest) async throws -> URLRequest
    }
    
    /// Protocol for intercepting and modifying network responses before they are processed
    public protocol ResponseInterceptor {
        /// Intercept and potentially modify a response after it is received
        /// - Parameters:
        ///   - response: The URLResponse received
        ///   - data: The data received
        /// - Returns: The modified data
        func intercept(_ response: URLResponse, data: Data) async throws -> Data
    }
    
    /// Default request interceptor that adds authentication token if required
    public final class AuthRequestInterceptor: RequestInterceptor {
        private let tokenManager: TokenManager
        
        public init(tokenManager: TokenManager = .shared) {
            self.tokenManager = tokenManager
        }
        
        public func intercept(_ request: URLRequest) async throws -> URLRequest {
            var request = request
            
            // Check if we need to add auth token
            if let token = try? tokenManager.getToken() {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            return request
        }
    }
    
    /// Default response interceptor that handles common error cases
    public final class ErrorResponseInterceptor: ResponseInterceptor {
        public init() {}
        
        public func intercept(_ response: URLResponse, data: Data) async throws -> Data {
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 404:
                throw APIError.notFound
            case 500...599:
                let error = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                throw APIError.serverError(error?.message ?? "Unknown server error")
            default:
                throw APIError.unknown(httpResponse.statusCode)
            }
        }
    }
    
    /// Response for error cases
    private struct ErrorResponse: Decodable {
        let message: String
    }
}
