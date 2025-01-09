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
    
    private let apiService = APIService.shared
    
    public init() {}
    
    public func sendResetEmail() async {
        guard !email.isEmpty else {
            errorMessage = "請輸入電子郵件"
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let response = try await apiService.forgotPassword(email: email)
            successMessage = response.message
            email = "" // Clear email after successful request
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "發生錯誤，請稍後再試"
        }
        
        isLoading = false
    }
}
#endif
