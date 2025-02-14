import Foundation

extension BMNetwork {
    // MARK: - URL Form Encoder
    final class URLFormEncoder {
        func encode<T: Encodable>(_ value: T) throws -> Data {
            let encoder = FormValueEncoder()
            try value.encode(to: encoder)
            let pairs = encoder.values.map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            return pairs.joined(separator: "&").data(using: .utf8) ?? Data()
        }
    }
    
    private class FormValueEncoder: Encoder {
        var codingPath: [CodingKey] = []
        var userInfo: [CodingUserInfoKey : Any] = [:]
        var values: [String: String] = [:]
        
        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            return KeyedEncodingContainer(FormKeyedEncoder(encoder: self))
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            fatalError("Unkeyed encoding not supported for form data")
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            fatalError("Single value encoding not supported for form data")
        }
        
        private struct FormKeyedEncoder<Key: CodingKey>: KeyedEncodingContainerProtocol {
            var codingPath: [CodingKey] = []
            let encoder: FormValueEncoder
            
            mutating func encodeNil(forKey key: Key) throws {}
            
            mutating func encode(_ value: String, forKey key: Key) throws {
                encoder.values[key.stringValue] = value
            }
            
            mutating func encode(_ value: Bool, forKey key: Key) throws {
                encoder.values[key.stringValue] = value ? "true" : "false"
            }
            
            mutating func encode(_ value: Int, forKey key: Key) throws {
                encoder.values[key.stringValue] = "\(value)"
            }
            
            mutating func encode(_ value: Double, forKey key: Key) throws {
                encoder.values[key.stringValue] = "\(value)"
            }
            
            mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
                encoder.values[key.stringValue] = "\(value)"
            }
            
            mutating func encodeIfPresent(_ value: String?, forKey key: Key) throws {
                if let value = value {
                    try encode(value, forKey: key)
                }
            }
            
            mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
                fatalError("Nested encoding not supported for form data")
            }
            
            mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
                fatalError("Nested unkeyed encoding not supported for form data")
            }
            
            mutating func superEncoder() -> Encoder {
                fatalError("Super encoding not supported for form data")
            }
            
            mutating func superEncoder(forKey key: Key) -> Encoder {
                fatalError("Super encoding not supported for form data")
            }
        }
    }
    
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
            ),
            session: {
                let config = URLSessionConfiguration.default
                config.waitsForConnectivity = false  // Don't wait for connectivity
                config.timeoutIntervalForRequest = 30  // 30 second timeout
                config.timeoutIntervalForResource = 30  // 30 second timeout
                return URLSession(configuration: config)
            }()
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
            
            // Always use endpoint's baseURL if provided
            if let endpointBaseURL = request.endpoint.baseURL {
                components.scheme = endpointBaseURL.scheme
                components.host = endpointBaseURL.host
                components.path = request.endpoint.path
            } else {
                // Fall back to configuration's baseURL
                components.scheme = configuration.baseURL.scheme
                components.host = configuration.baseURL.host
                components.path = request.endpoint.path
            }
            components.queryItems = request.queryItems ?? request.endpoint.queryItems
            
            guard let url = components.url else {
                throw BMNetwork.APIError.invalidURL
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.endpoint.method.rawValue
            
            // Set timeout and cache policy
            urlRequest.timeoutInterval = request.endpoint.timeoutInterval ?? configuration.timeoutInterval
            urlRequest.cachePolicy = request.endpoint.cachePolicy ?? configuration.cachePolicy
            
            // If endpoint provides Content-Type, use only endpoint headers
            if request.endpoint.headers["Content-Type"] != nil {
                print("DEBUG: Using endpoint-specific headers only")
                request.endpoint.headers.forEach { key, value in
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            } else {
                // Apply endpoint-specific headers first
                request.endpoint.headers.forEach { key, value in
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
                
                // Only apply default headers if no Content-Type is specified
                configuration.defaultHeaders.forEach { key, value in
                    if urlRequest.value(forHTTPHeaderField: key) == nil {
                        urlRequest.setValue(value, forHTTPHeaderField: key)
                    }
                }
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
            print("DEBUG: Preparing request body")
            if let body = request.body {
                print("DEBUG: Request body type: \(type(of: body))")
                print("DEBUG: Endpoint type: \(type(of: request.endpoint))")
                if let customEncoder = request.endpoint as? RequestBodyEncodable {
                    print("DEBUG: Using custom request body encoder")
                    // Use endpoint's custom encoding if available
                    urlRequest.httpBody = try customEncoder.encodeRequestBody(request: body)
                    print("DEBUG: Request body size: \(urlRequest.httpBody?.count ?? 0) bytes")
                    if let bodyString = String(data: urlRequest.httpBody ?? Data(), encoding: .utf8) {
                        print("DEBUG: First 500 chars of request body:\n\(String(bodyString.prefix(500)))")
                    }
                } else {
                    print("DEBUG: Using default JSON encoder")
                    // Default to JSON encoding
                    let encoder = JSONEncoder()
                    encoder.keyEncodingStrategy = .useDefaultKeys // Don't convert to snake case, use the keys as defined
                    urlRequest.httpBody = try encoder.encode(body)
                    print("DEBUG: Request body size: \(urlRequest.httpBody?.count ?? 0) bytes")
                    if let bodyString = String(data: urlRequest.httpBody ?? Data(), encoding: .utf8) {
                        print("DEBUG: Request body JSON:\n\(bodyString)")
                    }
                }
            }
            
            // Debug logging
            print("Request URL: \(urlRequest.url?.absoluteString ?? "")")
            print("Request Method: \(urlRequest.httpMethod ?? "")")
            print("Request Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
            
            // Final request validation
            print("DEBUG: Final request validation:")
            print("- URL: \(urlRequest.url?.absoluteString ?? "nil")")
            print("- Method: \(urlRequest.httpMethod ?? "nil")")
            print("- Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
            print("- Body size: \(urlRequest.httpBody?.count ?? 0) bytes")
            if let body = urlRequest.httpBody, let preview = String(data: body.prefix(200), encoding: .utf8) {
                print("- Body preview: \(preview)")
            }
            
            return urlRequest
        }
    }
}
