#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import Combine

public final class LoginViewModel: ObservableObject {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published private(set) public var errorMessage: String?
    @Published private(set) public var isLoggedIn: Bool = false
    @Published private(set) public var isFirstLogin: Bool = false
    
    private let authService: AuthServiceProtocol
    private let tokenManager: TokenManagerProtocol
    
    public init(
        authService: AuthServiceProtocol = AuthService.shared,
        tokenManager: TokenManagerProtocol = TokenManager.shared
    ) {
        self.authService = authService
        self.tokenManager = tokenManager
        logDebug("LoginViewModel initialized")
        
        // Check if user is already logged in
        Task {
            await checkLoginStatus()
        }
    }
    
    @MainActor
    private func checkLoginStatus() async {
        do {
            if tokenManager.isTokenValid {
                let expiry = try tokenManager.getTokenExpiry()
                logInfo("Found valid token expiring at \(expiry)")
                isLoggedIn = true
                
                // Refresh token if needed
                if try await tokenManager.refreshTokenIfNeeded(threshold: 3600) {
                    logInfo("Token refreshed successfully")
                }
            }
        } catch {
            logWarning("No valid token found: \(error.localizedDescription)")
            isLoggedIn = false
        }
    }
    
    @MainActor
    public func login() async {
        logInfo("Starting login process...")
        isLoading = true
        errorMessage = nil
        
        do {
            // Basic validation
            guard !email.isEmpty else {
                logWarning("Login attempt with empty email")
                errorMessage = "請輸入電子郵件"
                isLoading = false
                return
            }
            
            guard !password.isEmpty else {
                logWarning("Login attempt with empty password")
                errorMessage = "請輸入密碼"
                isLoading = false
                return
            }
            
            logInfo("Attempting login with email: \(email)")
            // Call login API and get raw response
            let response = try await authService.login(email: email, password: password) as [String: Any]
            
            logInfo("Login successful")
            
            // Token is already saved by APIClient
            isFirstLogin = response["first_login"] as? Bool ?? false
            isLoggedIn = true
            errorMessage = nil
            
        } catch let authError as AuthError {
            logError("Auth Error: \(authError.localizedDescription)")
            errorMessage = authError.localizedDescription
        } catch let apiError as APIError {
            logError("API Error: \(apiError.localizedDescription)")
            errorMessage = apiError.localizedDescription
        } catch let tokenError as TokenError {
            logError("Token Error: \(tokenError.localizedDescription)")
            errorMessage = tokenError.localizedDescription
        } catch {
            logError("Unexpected Error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    public func logout() {
        do {
            try tokenManager.clearToken()
            isLoggedIn = false
            isFirstLogin = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#endif
