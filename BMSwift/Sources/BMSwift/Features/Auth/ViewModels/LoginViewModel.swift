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
    
    public init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    @MainActor
    public func login() async {
        print("🔑 Starting login process...")
        isLoading = true
        errorMessage = nil
        
        do {
            // Basic validation
            guard !email.isEmpty else {
                print("❌ Email is empty")
                errorMessage = "請輸入電子郵件"
                isLoading = false
                return
            }
            
            guard !password.isEmpty else {
                print("❌ Password is empty")
                errorMessage = "請輸入密碼"
                isLoading = false
                return
            }
            
            print("📧 Attempting login with email: \(email)")
            // Call login API
            let response = try await authService.login(email: email, password: password)
            
            print("✅ Login successful")
            print("🔑 Token received: \(response.token)")
            print("⏰ Token expires at: \(response.expiredAt)")
            print("👤 First login: \(response.firstLogin)")
            
            // Store token (You might want to move this to a separate TokenManager)
            UserDefaults.standard.set(response.token, forKey: "userToken")
            UserDefaults.standard.set(response.expiredAt, forKey: "tokenExpiredAt")
            
            isFirstLogin = response.firstLogin
            isLoggedIn = true
            errorMessage = nil
            
        } catch let authError as AuthError {
            print("❌ Auth Error: \(authError.localizedDescription)")
            errorMessage = authError.localizedDescription
        } catch let apiError as APIError {
            print("❌ API Error: \(apiError.localizedDescription)")
            errorMessage = apiError.localizedDescription
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
#endif
