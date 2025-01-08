#if canImport(SwiftUI) && os(iOS)
import Foundation

public enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case serverError(String)
    case decodingError(Error)
    case encodingError(Error)
    
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
        case .decodingError(let error):
            return "資料解析錯誤: \(error.localizedDescription)"
        case .encodingError(let error):
            return "資料編碼錯誤: \(error.localizedDescription)"
        }
    }
}

public protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func requestRaw(_ endpoint: APIEndpoint) async throws -> [String: Any]
}

public class APIClient: APIClientProtocol {
    public static let shared = APIClient()
    
    private let baseURL = "https://wiki.kinglyrobot.com/api"
    private let session: URLSession
    private let encoder: JSONEncoder
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    private func createURLRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        let fullURL = "\(baseURL)\(endpoint.path)"
        guard let url = URL(string: fullURL) else {
            print("❌ Invalid URL: \(fullURL)")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if let body = endpoint.body {
            do {
                let jsonData = try encoder.encode(body)
                request.httpBody = jsonData
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("📤 Request Body: \(jsonString)")
                }
            } catch {
                print("❌ Failed to encode request body: \(error)")
                throw APIError.encodingError(error)
            }
        }
        
        print("🌐 Making request to: \(fullURL)")
        print("📋 Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        return request
    }
    
    private func handleRawResponse(_ data: Data, _ response: URLResponse) throws -> [String: Any] {
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw APIError.invalidResponse
        }
        
        print("📥 Response Status Code: \(httpResponse.statusCode)")
        
        // Log raw response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Response Body: \(jsonString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Server Error: \(httpResponse.statusCode)")
            throw APIError.serverError("伺服器錯誤: \(httpResponse.statusCode)")
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw APIError.invalidResponse
            }
            
            // Check if we have a token and expiry
            if let token = json["token"] as? String {
                if let expiresAt = json["expires_at"] as? String {
                    print("✅ Found token and expiry, saving to TokenManager")
                    try TokenManager.shared.saveToken(token, expiry: expiresAt)
                }
            }
            
            return json
        } catch {
            print("❌ JSON Parsing Error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let json = try await requestRaw(endpoint)
        return json as! T // We know this is safe for raw dictionary responses
    }
    
    public func requestRaw(_ endpoint: APIEndpoint) async throws -> [String: Any] {
        do {
            let request = try createURLRequest(for: endpoint)
            let (data, response) = try await session.data(for: request)
            return try handleRawResponse(data, response)
        } catch let error as APIError {
            print("❌ API Error: \(error.localizedDescription)")
            throw error
        } catch {
            print("❌ Network Error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }
}
#endif
