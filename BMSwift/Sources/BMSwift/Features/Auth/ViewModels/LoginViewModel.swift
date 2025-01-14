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
    }
    
    @MainActor
    public func login() async {
        print("[Login] Starting login process...")
        isLoading = true
        errorMessage = nil
        
        do {
            print("[Login] Making login request...")
            let response = try await authService.login(email: email, password: password)
            print("[Login] Login successful! Token received.")
            
            // Save the token and update authentication
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let expiresAtString = dateFormatter.string(from: response.expiresAt)
            await authActor.saveAuthentication(token: response.token, expiresAt: expiresAtString)
            
            self.token = response.token
            self.isLoggedIn = true
            
            // Show success message
            self.errorMessage = "成功登入"
            
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
    }
}
#endif
