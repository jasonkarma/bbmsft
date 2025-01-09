#if canImport(SwiftUI) && os(iOS)
import Foundation

public enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case serverError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無效的URL"
        case .invalidResponse:
            return "無效的回應"
        case .networkError(let error):
            return "網路錯誤: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        }
    }
}

public protocol APIClientProtocol {
    func request(_ endpoint: APIEndpoint) async throws -> [String: Any]
}

public class APIClient: APIClientProtocol {
    public static let shared = APIClient()
    private let baseURL = "https://wiki.kinglyrobot.com/api"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }
    
    public func request(_ endpoint: APIEndpoint) async throws -> [String: Any] {
        // Create URL
        let fullURL = "\(baseURL)\(endpoint.path)"
        guard let url = URL(string: fullURL) else {
            throw APIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        // Add body if present
        if let body = endpoint.body {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
            print("📤 Request: \(String(data: jsonData, encoding: .utf8) ?? "")")
        }
        
        // Make request
        let (data, response) = try await session.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Log response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Response: \(jsonString)")
        }
        
        // Check status code
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError("伺服器錯誤: \(httpResponse.statusCode)")
        }
        
        // Parse JSON
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.invalidResponse
        }
        
        return json
    }
}
#endif
