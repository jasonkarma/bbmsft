#if canImport(SwiftUI) && os(iOS)
import Foundation
import SwiftUI

@MainActor
public class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private let tokenManager = TokenManager.shared
    
    public init() {
        // Check if user is already logged in
        isLoggedIn = tokenManager.isAuthenticated
    }
    
    public func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "請輸入電子郵件和密碼"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.login(email: email, password: password)
            print("Login successful: \(response)")  // Debug print
            
            // Save token
            try tokenManager.saveToken(response.token, expiry: response.expiredAt)
            isLoggedIn = true
            
            if response.firstLogin {
                // Handle first login flow if needed
                print("First time login")  // Debug print
            }
        } catch let error as APIError {
            print("API Error: \(error.localizedDescription)")  // Debug print
            errorMessage = error.localizedDescription
            isLoggedIn = false
        } catch {
            print("Unknown Error: \(error)")  // Debug print
            errorMessage = "發生錯誤，請稍後再試"
            isLoggedIn = false
        }
        
        isLoading = false
    }
    
    public func logout() {
        tokenManager.clearToken()
        isLoggedIn = false
        email = ""
        password = ""
        errorMessage = nil
    }
}
#endif
