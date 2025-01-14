import Foundation

extension BMNetwork {
    struct ErrorResponse: Codable {
        let error: String
    }
    
    public final class NetworkClient {
        // MARK: - Properties
        private let baseURL: URL
        private let session: URLSession
        
        // MARK: - Shared Instance
        public static let shared = NetworkClient(baseURL: URL(string: "https://wiki.kinglyrobot.com")!)
        
        // MARK: - Initialization
        public init(baseURL: URL,
                   session: URLSession = .shared) {
            self.baseURL = baseURL
            self.session = session
        }
        
        // MARK: - API Methods
        public func send<E: BMNetwork.APIEndpoint>(_ request: BMNetwork.APIRequest<E>) async throws -> E.ResponseType {
            let urlRequest = try createURLRequest(for: request)
            
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BMNetwork.APIError.invalidResponse
            }
            
            // Debug logging
            print("Response Status Code: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw Response Body: \(responseString)")
                
                // Try parsing as dictionary for debugging
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("JSON Keys: \(json.keys.joined(separator: ", "))")
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    // Create a fresh decoder for each request
                    let decoder = JSONDecoder()
                    
                    // Configure decoder for date formatting only
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    // Print raw JSON structure for debugging
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) {
                        print("Parsed JSON structure: \(jsonObject)")
                    }
                    
                    return try decoder.decode(E.ResponseType.self, from: data)
                } catch {
                    print("Decoding error: \(error)")
                    throw error
                }
            case 401:
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw BMNetwork.APIError.serverError(errorResponse.error)
                }
                throw BMNetwork.APIError.unauthorized
            case 404:
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw BMNetwork.APIError.serverError(errorResponse.error)
                }
                throw BMNetwork.APIError.notFound
            default:
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw BMNetwork.APIError.serverError(errorResponse.error)
                } else if let errorMessage = String(data: data, encoding: .utf8) {
                    throw BMNetwork.APIError.serverError(errorMessage)
                } else {
                    throw BMNetwork.APIError.serverError("Unknown server error")
                }
            }
        }
        
        // MARK: - Helper Methods
        private func createURLRequest<E: BMNetwork.APIEndpoint>(for request: BMNetwork.APIRequest<E>) throws -> URLRequest {
            // Create URL components
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = request.endpoint.path
            components.queryItems = request.queryItems
            
            // Create URL
            guard let url = components.url else {
                throw BMNetwork.APIError.invalidURL
            }
            
            // Create URLRequest
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.endpoint.method.rawValue
            
            // Set Content-Type header for JSON
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
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
                
                // Debug logging
                if let jsonString = String(data: urlRequest.httpBody!, encoding: .utf8) {
                    print("Request Body: \(jsonString)")
                }
            }
            
            // Debug logging
            print("Request URL: \(urlRequest.url?.absoluteString ?? "")")
            print("Request Method: \(urlRequest.httpMethod ?? "")")
            print("Request Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
            
            return urlRequest
        }
    }
}
