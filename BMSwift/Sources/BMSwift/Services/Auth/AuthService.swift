#if canImport(SwiftUI) && os(iOS)
import Foundation

public enum AuthError: LocalizedError {
    case invalidResponse
    case networkError(Error)
    case serverError(String)
    case tokenError(Error)
    case registrationError([String])
    
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
        case .registrationError(let errors):
            return errors.joined(separator: "\n")
        }
    }
}

public protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> Bool
    func forgotPassword(email: String) async throws -> ForgotPasswordResponse
    func register(email: String, username: String, password: String) async throws -> RegisterResponse
}

public class AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol
    private let tokenManager: TokenManagerProtocol
    
    public static let shared = AuthService()
    
    public init(
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
            
            // Try to decode the response
            let jsonData = try JSONSerialization.data(withJSONObject: response)
            let decoder = JSONDecoder()
            let forgotPasswordResponse = try decoder.decode(ForgotPasswordResponse.self, from: jsonData)
            
            // Check for error
            if let error = forgotPasswordResponse.error {
                throw AuthError.serverError(error)
            }
            
            return forgotPasswordResponse
            
        } catch let error as APIError {
            print("❌ API Error: \(error.localizedDescription)")
            throw AuthError.networkError(error)
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            throw AuthError.serverError("無效的回應")
        }
    }
    
    public func register(email: String, username: String, password: String) async throws -> RegisterResponse {
        let request = RegisterRequest(email: email, username: username, password: password)
        let endpoint = APIEndpoints.Auth.register(request: request)
        
        do {
            let response = try await apiClient.request(endpoint)
            
            if let errorArray = response["error"] as? [String] {
                throw AuthError.registrationError(errorArray)
            }
            
            return RegisterResponse(message: "註冊成功")
        } catch let error as APIError {
            print("❌ API Error: \(error.localizedDescription)")
            throw AuthError.networkError(error)
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            throw AuthError.serverError("註冊失敗")
        }
    }
}
#endif
