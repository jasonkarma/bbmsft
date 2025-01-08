#if canImport(SwiftUI) && os(iOS)
import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public struct APIRequest<RequestType: Encodable, ResponseType: Decodable> {
    public let endpoint: String
    public let method: HTTPMethod
    public let body: RequestType?
    
    public init(endpoint: String, method: HTTPMethod, body: RequestType? = nil) {
        self.endpoint = endpoint
        self.method = method
        self.body = body
    }
}

@available(iOS 15.0, *)
public final class NetworkService {
    public static let shared = NetworkService()
    private let baseURL = "https://wiki.kinglyrobot.com/api"
    
    private init() {}
    
    public func request<RequestType: Encodable, ResponseType: Decodable>(
        _ request: APIRequest<RequestType, ResponseType>
    ) async throws -> ResponseType {
        let urlString = request.endpoint.hasPrefix("http") ? request.endpoint : baseURL + request.endpoint
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = request.body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(ResponseType.self, from: data)
        } else {
            if let errorResponse = try? JSONDecoder().decode(NetworkError.self, from: data) {
                throw errorResponse
            } else {
                throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
            }
        }
    }
}
#endif
