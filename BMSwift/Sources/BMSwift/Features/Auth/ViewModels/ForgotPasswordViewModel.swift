#if canImport(SwiftUI) && os(iOS)
import Foundation
import SwiftUI

@available(iOS 13.0, *)
@MainActor
public class ForgotPasswordViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var successMessage: String?
    
    private let authService: AuthServiceProtocol
    
    public init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    public func sendResetEmail() async {
        guard !email.isEmpty else {
            errorMessage = "請輸入電子郵件"
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let response = try await authService.forgotPassword(email: email)
            if let message = response.message {
                successMessage = message
                email = "" // Clear email after successful request
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        
        isLoading = false
    }
}
#endif
