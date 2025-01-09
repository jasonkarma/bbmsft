#if canImport(SwiftUI) && os(iOS)
import Foundation
import Combine

@MainActor
public class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isPasswordValid: Bool = false
    @Published var errorMessage: String = ""
    @Published var isRegistered: Bool = false
    @Published var isLoading: Bool = false
    
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        setupPasswordValidation()
    }
    
    private func setupPasswordValidation() {
        $password
            .map { password in
                let hasMinLength = password.count >= 8
                let hasUppercase = password.contains { $0.isUppercase }
                let hasLowercase = password.contains { $0.isLowercase }
                return hasMinLength && hasUppercase && hasLowercase
            }
            .assign(to: &$isPasswordValid)
    }
    
    func register() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await authService.register(
                email: email,
                username: username,
                password: password
            )
            isRegistered = true
            errorMessage = ""
        } catch let error as APIError {
            switch error {
            case .validationError(let errors):
                if let emailErrors = errors["email"] {
                    errorMessage = "此電子郵件已被使用"
                } else if let usernameErrors = errors["username"] {
                    errorMessage = "此暱稱已被使用"
                } else {
                    errorMessage = error.localizedDescription
                }
            case .networkError(_):
                errorMessage = "網路連線錯誤，請稍後再試"
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "註冊失敗，請稍後再試"
            }
            isRegistered = false
        } catch let error as AuthError {
            switch error {
            case .registrationError(let errors):
                errorMessage = errors.joined(separator: "\n")
            default:
                errorMessage = error.localizedDescription
            }
            isRegistered = false
        } catch {
            errorMessage = "註冊失敗，請稍後再試"
            isRegistered = false
        }
        
        isLoading = false
    }
}
#endif
