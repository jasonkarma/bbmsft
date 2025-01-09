#if canImport(SwiftUI) && os(iOS)
import Foundation
import Combine

@MainActor
public class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isPasswordValid: Bool = false
    @Published var errorMessage: String?
    @Published var isRegistered: Bool = false
    @Published var isLoading: Bool = false
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
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
    
    public func register() async {
        guard !isLoading else { return }
        guard isPasswordValid else {
            errorMessage = "密碼必須至少8個字符，包含大小寫字母"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "密碼不一致"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.register(
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )
            isRegistered = true
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "發生錯誤，請稍後再試"
        }
        
        isLoading = false
    }
}
#endif
