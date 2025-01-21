#if canImport(SwiftUI) && os(iOS)
import Foundation
import BMNetwork

@MainActor
public class RegisterViewModel: ObservableObject {
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
    
    private let client: BMNetworkcl.NetworkClient
    
    public init(client: BMNetworkcl.NetworkClient = BMNetworkcl.NetworkClient.shared) {
        self.client = client
    }
    
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
            let request = AuthEndpoints.register(
                email: email,
                password: password,
                username: username
            )
            let response = try await client.send(request)
            
            // Show success alert
            alertMessage = response.message
            showAlert = true
            isRegistered = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func dismissAlert() {
        showAlert = false
        shouldDismiss = true  // Always dismiss when alert is closed
    }
    
    private func isValidPassword(_ password: String) -> Bool {
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
