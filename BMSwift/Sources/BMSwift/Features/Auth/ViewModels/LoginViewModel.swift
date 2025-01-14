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
    
    private let apiService = APIService.shared
    private let authActor = AuthenticationActor.shared
    
    public init() {
        Task {
            isLoggedIn = await authActor.isAuthenticated
        }
    }
    
    public func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "請輸入電子郵件和密碼"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Validate password
        if !isValidPassword(password) {
            errorMessage = "密碼需大於8字．且有大小寫英文"
            isLoading = false
            return
        }
        
        do {
            let response = try await apiService.login(email: email, password: password)
            isLoggedIn = true
            
            if response.firstLogin {
                // Handle first login flow if needed
                print("First time login")
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            isLoggedIn = false
        } catch {
            errorMessage = "登入失敗，請稍後再試"
            isLoggedIn = false
        }
        
        isLoading = false
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z]).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
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
