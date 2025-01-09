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
    
    public init() {}
    
    public func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "請輸入電子郵件和密碼"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.login(email: email, password: password)
            isLoggedIn = true
            if response.firstLogin {
                // Handle first login flow
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "發生錯誤，請稍後再試"
        }
        
        isLoading = false
    }
    
    public func logout() {
        apiService.logout()
        isLoggedIn = false
        email = ""
        password = ""
        errorMessage = nil
    }
}
#endif
