#if canImport(SwiftUI) && os(iOS)
import Foundation
import SwiftUI

@available(iOS 13.0, *)
public class ForgotPasswordViewModel: ObservableObject {
    private let authService: AuthServiceProtocol
    
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    public init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    @MainActor
    public func sendResetEmail() async {
        guard !email.isEmpty else {
            errorMessage = "請輸入電子郵件"
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "請輸入有效的電子郵件"
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let response = try await authService.forgotPassword(email: email)
            successMessage = response.message
            // Clear the email field after successful submission
            email = ""
        } catch {
            errorMessage = "發送重置密碼郵件失敗，請稍後再試"
        }
        
        isLoading = false
    }
}
#endif
