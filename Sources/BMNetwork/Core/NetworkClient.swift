import Foundation

/// A namespace for network-related functionality
public enum BMNetworkcl {}

public extension BMNetworkcl {
    /// A client for making network requests
    final class NetworkClient {
        // MARK: - Properties
        private let session: URLSession
        private let defaultBaseURL: URL
        
        // MARK: - Shared Instance
        public static let shared = NetworkClient(defaultBaseURL: URL(string: "https://wiki.kinglyrobot.com")!)
        
        // MARK: - Initialization
        public init(defaultBaseURL: URL = URL(string: "https://wiki.kinglyrobot.com")!,
                   session: URLSession = .shared) {
            self.defaultBaseURL = defaultBaseURL
            self.session = session
        }
        
        // MARK: - API Methods
        public func send<E: BMNetwork.APIEndpoint>(_ request: BMNetwork.APIRequest<E>) async throws -> E.ResponseType {
            let urlRequest = try createURLRequest(for: request)
            
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BMNetwork.APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    // Special case for ArticleDetail endpoint - use default key decoding
                    if E.self == EncyclopediaEndpoints.ArticleDetail.self {
                        decoder.keyDecodingStrategy = .useDefaultKeys
                    } else {
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                    }
                    return try decoder.decode(E.ResponseType.self, from: data)
                } catch {
                    throw BMNetwork.APIError.serverError("Failed to decode response: \(error)")
                }
            case 401:
                throw BMNetwork.APIError.unauthorized
            case 404:
                throw BMNetwork.APIError.notFound
            default:
                if let errorResponse = try? JSONDecoder().decode(BMNetwork.ErrorResponse.self, from: data) {
                    throw BMNetwork.APIError.serverError(errorResponse.error)
                } else {
                    throw BMNetwork.APIError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
            }
        }
        
        // MARK: - Private Methods
        private func createURLRequest<E: BMNetwork.APIEndpoint>(for request: BMNetwork.APIRequest<E>) throws -> URLRequest {
            // Use endpoint's base URL if provided, otherwise use default
            let baseURL = request.endpoint.baseURL ?? defaultBaseURL
            
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
            components?.path = request.endpoint.path
            components?.queryItems = request.queryItems
            
            guard let url = components?.url else {
                throw BMNetwork.APIError.invalidURL
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.endpoint.method.rawValue
            
            // Add endpoint-specific headers first
            request.endpoint.headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
            
            // Add auth token if needed (only for internal APIs)
            if !request.endpoint.isExternalAPI && request.endpoint.requiresAuth {
                if let token = request.authToken {
                    urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
            }
            
            // Add body if present
            if let body = request.body {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                urlRequest.httpBody = try encoder.encode(body)
            }
            
            return urlRequest
        }
    }
}
