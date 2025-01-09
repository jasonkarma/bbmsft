#if canImport(SwiftUI) && os(iOS)
import Foundation

public enum AuthError: LocalizedError {
    case invalidResponse
    case networkError(Error)
    case serverError(String)
    case tokenError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "無效的回應"
        case .networkError(let error):
            return "網路錯誤: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .tokenError(let error):
            return "登入憑證錯誤: \(error.localizedDescription)"
        }
    }
}

public protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> Bool
    func forgotPassword(email: String) async throws -> ForgotPasswordResponse
}

public class AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol
    private let tokenManager: TokenManagerProtocol
    
    public static let shared = AuthService()
    
    private init(
        apiClient: APIClientProtocol = APIClient.shared,
        tokenManager: TokenManagerProtocol = TokenManager.shared
    ) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
    }
    
    public func login(email: String, password: String) async throws -> Bool {
        let request = LoginRequest(email: email, password: password)
        let endpoint = APIEndpoints.Auth.login(request: request)
        
        do {
            let response = try await apiClient.request(endpoint)
            print("✅ Full API Response: \(response)") // Debug print
            
            // Extract token and expiry
            guard let token = response["token"] as? String,
                  let expiresAt = response["expires_at"] as? String else {
                print("❌ Missing token or expiry in response")
                throw AuthError.invalidResponse
            }
            
            print("✅ Received token: \(token)")
            print("✅ Received expiry: \(expiresAt)")
            
            // Save token
            try tokenManager.saveToken(token, expiry: expiresAt)
            print("✅ Token saved successfully")
            
            // Return first login status - check both possible keys
            let isFirstLogin = (response["first_login"] as? Bool) ?? (response["firstLogin"] as? Bool) ?? false
            print("✅ First login status: \(isFirstLogin)")
            return isFirstLogin
            
        } catch let error as APIError {
            print("❌ API Error: \(error.localizedDescription)")
            throw AuthError.networkError(error)
        } catch let error as TokenError {
            print("❌ Token Error: \(error.localizedDescription)")
            throw AuthError.tokenError(error)
        }
    }
    
    public func forgotPassword(email: String) async throws -> ForgotPasswordResponse {
        let request = ForgotPasswordRequest(email: email)
        let endpoint = APIEndpoints.Auth.forgotPassword(request: request)
        
        do {
            let response = try await apiClient.request(endpoint)
            return ForgotPasswordResponse(message: "重設密碼郵件已發送")
        } catch let error as APIError {
            print("❌ API Error: \(error.localizedDescription)")
            throw AuthError.networkError(error)
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            throw AuthError.serverError("發送重設密碼郵件失敗")
        }
    }
}
#endif
