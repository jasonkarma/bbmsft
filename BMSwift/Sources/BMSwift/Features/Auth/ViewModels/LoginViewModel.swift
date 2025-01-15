#if canImport(SwiftUI) && os(iOS)
import Foundation
import SwiftUI

@MainActor
public class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var showPasswordWarning = false
    @Published private(set) var token: String?
    
    private let client: BMNetwork.NetworkClient
    private let authActor = AuthenticationActor.shared
    private let authService: AuthService
    
    public init(client: BMNetwork.NetworkClient = BMNetwork.NetworkClient.shared, authService: AuthService = AuthService.shared) {
        self.client = client
        self.authService = authService
    }
    
    public func checkAuthenticationStatus() async {
        isLoggedIn = await authActor.isAuthenticated
        if isLoggedIn {
            // Get token from the response instead of directly from authActor
            let response = try? await authService.getCurrentSession()
            token = response?.token
        }
    }
    
    @MainActor
    public func login() async {
        print("[Login] Starting login process...")
        isLoading = true
        errorMessage = nil
        token = nil // Reset token
        
        do {
            print("[Login] Making login request...")
            let response = try await authService.login(email: email, password: password)
            print("[Login] Login successful! Token received.")
            
            // Save the token and update authentication
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let expiresAtString = dateFormatter.string(from: response.expiresAt)
            await authActor.saveAuthentication(token: response.token, expiresAt: expiresAtString)
            
            // Show success message first
            self.errorMessage = "成功登入"
            
            // Set isLoggedIn and token after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isLoggedIn = true
                self.token = response.token // This will trigger navigation
            }
            
            if response.firstLogin {
                print("[Login] First time login detected")
            }
            
        } catch {
            print("[Login] Login failed with error: \(error)")
            errorMessage = error.localizedDescription
            isLoggedIn = false
            token = nil
        }
        
        isLoading = false
    }
    
    public func validatePasswordInput() {
        showPasswordWarning = !isValidPassword(password)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // Password must be at least 8 characters long and contain both uppercase and lowercase letters
        let hasUppercase = password.contains { $0.isUppercase }
        let hasLowercase = password.contains { $0.isLowercase }
        return password.count >= 8 && hasUppercase && hasLowercase
    }
    
    public func logout() async {
        await authActor.clearAuthentication()
        isLoggedIn = false
        email = ""
        password = ""
        errorMessage = nil
        token = nil
    }
}
#endif
