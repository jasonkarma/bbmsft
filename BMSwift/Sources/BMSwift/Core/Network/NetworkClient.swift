import Foundation

public final class NetworkClient {
    // MARK: - Properties
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    public init(baseURL: URL,
                session: URLSession = .shared,
                decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        
        // Configure decoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - API Methods
    public func send<E: APIEndpoint>(_ request: APIRequest<E>) async throws -> E.ResponseType {
        let urlRequest = try createURLRequest(for: request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(E.ResponseType.self, from: data)
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        default:
            if let errorMessage = String(data: data, encoding: .utf8) {
                throw APIError.serverError(errorMessage)
            } else {
                throw APIError.serverError("Unknown server error")
            }
        }
    }
    
    // MARK: - Helper Methods
    private func createURLRequest<E: APIEndpoint>(for request: APIRequest<E>) throws -> URLRequest {
        // Create URL components
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = request.endpoint.path
        components.queryItems = request.queryItems
        
        // Create URL
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        // Create URLRequest
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.endpoint.method.rawValue
        
        // Add headers
        request.endpoint.headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        // Add auth token if required
        if request.endpoint.requiresAuth, let token = request.authToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
