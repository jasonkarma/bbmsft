#if canImport(SwiftUI) && os(iOS)
import Foundation
import SwiftUI

@MainActor
public class LoginViewModel: ObservableObject {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isFirstLogin: Bool = false
    @Published public var isLoggedIn: Bool = false
    @Published public var shouldNavigateToForgotPassword: Bool = false
    @Published public var shouldNavigateToSignup: Bool = false
    
    private let authService: AuthServiceProtocol
    private let tokenManager: TokenManagerProtocol
    
    public var isPasswordValid: Bool {
        let hasMinLength = password.count >= 8
        let hasUppercase = password.contains { $0.isUppercase }
        return hasMinLength && hasUppercase
    }
    
    public init(
        authService: AuthServiceProtocol = AuthService.shared,
        tokenManager: TokenManagerProtocol = TokenManager.shared
    ) {
        self.authService = authService
        self.tokenManager = tokenManager
    }
    
    public func login() async {
        guard !email.isEmpty else {
            errorMessage = "請輸入電子郵件"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "請輸入密碼"
            return
        }
        
        guard isPasswordValid else {
            errorMessage = "密碼至少需要8個字元且包含一個大寫字母"
            return
        }
        
        print("[LoginViewModel] Starting login process...")
        isLoading = true
        errorMessage = nil
        
        do {
            print("[LoginViewModel] Attempting login with email: \(email)")
            isFirstLogin = try await authService.login(email: email, password: password)
            isLoggedIn = true
            print("[LoginViewModel] Login successful. First login: \(isFirstLogin)")
            
        } catch {
            print("[LoginViewModel] Login failed: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            isLoggedIn = false
        }
        
        isLoading = false
    }
    
    public func logout() async {
        isLoading = true
        
        do {
            try tokenManager.clearToken()
            isLoggedIn = false
            isFirstLogin = false
            errorMessage = nil
            email = ""
            password = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
#endif
