#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import Combine
import Foundation

@available(iOS 13.0, *)
@MainActor
public final class ForgotPasswordViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Current state of the password reset process
    @Published private(set) var state: ViewState = .idle
    
    /// Email input field
    @Published var email: String = ""
    
    // MARK: - Private Properties
    
    private let authService: AuthServiceProtocol
    
    // MARK: - Initialization
    
    /// Creates a new ForgotPasswordViewModel
    /// - Parameter authService: Service to handle authentication
    public init(authService: AuthServiceProtocol = AuthService(
        client: BMNetwork.NetworkClient(
            configuration: BMNetwork.Configuration(
                baseURL: URL(string: "https://wiki.kinglyrobot.com")!
            )
        )
    )) {
        self.authService = authService
    }
    
    // MARK: - Public Methods
    
    /// Validates the current email input
    /// - Returns: True if email is valid
    public func validateInput() -> Bool {
        guard !email.isEmpty else {
            state = .error(AuthModels.AuthError.invalidEmail)
            return false
        }
        
        // Basic email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            state = .error(AuthModels.AuthError.invalidEmail)
            return false
        }
        
        return true
    }
    
    /// Attempts to send a password reset email
    public func sendResetEmail() async {
        guard validateInput() else { return }
        
        state = .loading
        
        do {
            let response = try await authService.forgotPassword(email: email)
            state = .success(response)
        } catch let error as AuthModels.AuthError {
            state = .error(error)
        } catch {
            state = .error(AuthModels.AuthError.unknown(error.localizedDescription))
        }
    }
    
    /// Resets the view model state
    public func reset() {
        state = .idle
        email = ""
    }
    
    /// Represents the current state of the password reset process
    public enum ViewState: Equatable {
        /// Initial state, no reset attempt made
        case idle
        /// Reset request is in progress
        case loading
        /// Reset email sent successfully
        case success(AuthModels.ForgotPasswordResponse)
        /// Reset request failed with error
        case error(AuthModels.AuthError)
        
        public static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.loading, .loading):
                return true
            case (.success(let lhsResponse), .success(let rhsResponse)):
                return lhsResponse == rhsResponse
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
}
#endif
