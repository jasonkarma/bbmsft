#if canImport(SwiftUI) && os(iOS)
import Foundation
import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var shouldDismiss = false
    @Published var isRegistered = false
    @Published var showPasswordWarning = false
    
    private let apiService = APIService.shared
    
    func register() async {
        isLoading = true
        errorMessage = nil
        
        // Validate password
        if !isValidPassword(password) {
            errorMessage = "密碼需大於8字．且有大小寫英文"
            isLoading = false
            return
        }
        
        do {
            _ = try await apiService.register(
                username: username,
                email: email,
                password: password
            )
            
            // Show success alert
            alertMessage = "註冊成功"
            showAlert = true
            isRegistered = true
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "發生未知錯誤"
        }
        
        isLoading = false
    }
    
    func dismissAlert() {
        showAlert = false
        shouldDismiss = true  // Always dismiss when alert is closed
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let minLength = 8
        let hasUppercase = password.contains(where: { $0.isUppercase })
        let hasLowercase = password.contains(where: { $0.isLowercase })
        
        return password.count >= minLength && hasUppercase && hasLowercase
    }
    
    func validatePasswordInput() {
        showPasswordWarning = !password.isEmpty && !isValidPassword(password)
    }
}
#endif
