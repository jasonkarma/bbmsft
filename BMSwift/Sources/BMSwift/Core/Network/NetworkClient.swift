import Foundation

extension BMNetwork {
    struct ErrorResponse: Codable {
        let error: String
    }
    
    public final class NetworkClient: NetworkClientProtocol {
        // MARK: - Properties
        private let configuration: Configuration
        private let session: URLSession
        
        // MARK: - Shared Instance
        public static let shared = NetworkClient(
            configuration: Configuration(
                baseURL: URL(string: "https://wiki.kinglyrobot.com")!,
                defaultHeaders: [
                    "Content-Type": "application/json"
                ]
            )
        )
        
        // MARK: - Initialization
        public init(
            configuration: Configuration,
            session: URLSession = .shared
        ) {
            self.configuration = configuration
            self.session = session
        }
        
        // MARK: - Public Methods
        
        /// Sends an API request and returns the decoded response
        /// - Parameter request: The request to send
        /// - Returns: Decoded response of type specified by the endpoint
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
            case 500...599:
                let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
                throw BMNetwork.APIError.serverError(message)
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
        
        // MARK: - Private Methods
        
        private func createURLRequest<E: BMNetwork.APIEndpoint>(for request: BMNetwork.APIRequest<E>) throws -> URLRequest {
            // Create URL components
            var components = URLComponents()
            
            // Use endpoint's baseURL if provided, otherwise use configuration's baseURL
            let baseURL = request.endpoint.baseURL ?? configuration.baseURL
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = request.endpoint.path
            components.queryItems = request.queryItems ?? request.endpoint.queryItems
            
            guard let url = components.url else {
                throw BMNetwork.APIError.invalidURL
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.endpoint.method.rawValue
            
            // Set timeout and cache policy
            urlRequest.timeoutInterval = request.endpoint.timeoutInterval ?? configuration.timeoutInterval
            urlRequest.cachePolicy = request.endpoint.cachePolicy ?? configuration.cachePolicy
            
            // Apply default headers from configuration
            configuration.defaultHeaders.forEach { key, value in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            // Apply endpoint-specific headers (these override defaults)
            request.endpoint.headers.forEach { key, value in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            // Apply auth token if required
            if request.endpoint.requiresAuth {
                if let token = request.authToken {
                    urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    throw BMNetwork.APIError.unauthorized
                }
            }
            
            // Add request body if present
            if let body = request.body {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                urlRequest.httpBody = try encoder.encode(body)
            }
            
            // Debug logging
            print("Request URL: \(urlRequest.url?.absoluteString ?? "")")
            print("Request Method: \(urlRequest.httpMethod ?? "")")
            print("Request Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
            
            return urlRequest
        }
    }
}
