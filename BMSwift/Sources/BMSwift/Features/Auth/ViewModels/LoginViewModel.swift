#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import Combine

public final class LoginViewModel: ObservableObject {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var error: String?
    
    public init() {}
    
    @MainActor
    public func login() async {
        isLoading = true
        error = nil
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Basic validation
            guard !email.isEmpty else {
                error = "請輸入電子郵件"
                isLoading = false
                return
            }
            
            guard !password.isEmpty else {
                error = "請輸入密碼"
                isLoading = false
                return
            }
            
            // TODO: Implement actual login logic
            // For now, just simulate success/failure
            if email.contains("@") {
                // Success case
                error = nil
            } else {
                // Error case
                error = "無效的電子郵件格式"
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

#if DEBUG
extension LoginViewModel {
    static var preview: LoginViewModel {
        let viewModel = LoginViewModel()
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        return viewModel
    }
}
#endif
#endif
