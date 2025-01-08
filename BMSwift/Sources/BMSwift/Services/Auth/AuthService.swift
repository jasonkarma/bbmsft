import Foundation

public enum AuthError: LocalizedError {
    case invalidResponse
    case networkError(Error)
    case serverError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "無效的回應"
        case .networkError(let error):
            return "網路錯誤: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        }
    }
}

public protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> LoginResponse
}

public class AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol
    
    public static let shared = AuthService()
    
    private init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    public func login(email: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(email: email, password: password)
        let endpoint = APIEndpoints.Auth.login(request: request)
        return try await apiClient.request(endpoint)
    }
}
