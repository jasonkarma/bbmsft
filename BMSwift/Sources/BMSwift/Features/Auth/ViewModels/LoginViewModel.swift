#if canImport(SwiftUI) && os(iOS)
import Foundation
import SwiftUI

/// View model for handling login functionality
@MainActor
public final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Current state of the login process
    @Published private(set) var state: ViewState = .idle
    
    /// Email input field
    @Published var email: String = ""
    
    /// Password input field
    @Published var password: String = ""
    
    /// Whether to show the registration view
    @Published var showRegister: Bool = false
    
    /// Whether to show the forgot password view
    @Published var showForgotPassword: Bool = false
    
    /// Whether to show the password warning
    @Published var showPasswordWarning: Bool = false
    
    // MARK: - Private Properties
    
    private let authService: AuthServiceProtocol
    
    // MARK: - Initialization
    
    /// Creates a new LoginViewModel
    /// - Parameter authService: Service to handle authentication
    public init(authService: AuthServiceProtocol = AuthService(
        client: BMNetwork.NetworkClient(
            configuration: BMNetwork.Configuration(
                baseURL: URL(string: "https://wiki.kinglyrobot.com")!
            )
        )
    )) {
        print("🔑 [LoginViewModel] Initializing")
        self.authService = authService
    }
    
    // MARK: - Public Methods
    
    /// Attempts to log in with the current email and password
    public func login() async {
        print("🔑 [LoginViewModel] ====== LOGIN STARTED ======")
        guard !email.isEmpty && !password.isEmpty else {
            print("🔑 [LoginViewModel] Error: Invalid credentials")
            state = .error(AuthModels.AuthError.invalidCredentials)
            return
        }
        
        await login(email: email, password: password)
    }
    
    public func login(email: String, password: String) async {
        print("🔑 [LoginViewModel] ====== LOGIN STARTED ======")
        state = .loading
        
        do {
            let response = try await authService.login(email: email, password: password)
            print("🔑 [LoginViewModel] Got token: \(response.token.prefix(10))...")
            
            // Save the token
            TokenManager.shared.saveToken(response.token)
            print("🔑 [LoginViewModel] Token saved")
            
            state = .success(response)
            print("🔑 [LoginViewModel] ====== LOGIN SUCCESS ======")
            
            // Post login success notification
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
            
        } catch let error as AuthModels.AuthError {
            print("🔑 [LoginViewModel] ====== LOGIN FAILED ======")
            print("🔑 [LoginViewModel] Error: \(error.localizedDescription)")
            state = .error(error)
        } catch {
            print("🔑 [LoginViewModel] ====== LOGIN FAILED ======")
            print("🔑 [LoginViewModel] Error: \(error.localizedDescription)")
            state = .error(AuthModels.AuthError.unknown(error.localizedDescription))
        }
    }
    
    /// Resets the view model state
    public func reset() {
        print("🔑 [LoginViewModel] Resetting state")
        state = .idle
        email = ""
        password = ""
        showPasswordWarning = false
    }
    
    public func validatePasswordInput() {
        // showPasswordWarning is removed, but you might want to add a similar functionality
    }
    
    public func logout() async {
        // logout functionality is removed, but you might want to add a similar functionality
    }
}

// MARK: - ViewState Extension
extension LoginViewModel {
    /// Represents the current state of the login process
    public enum ViewState: Equatable {
        /// Initial state, no login attempt made
        case idle
        /// Login request is in progress
        case loading
        /// Login completed successfully
        case success(AuthModels.LoginResponse)
        /// Login failed with error
        case error(AuthModels.AuthError)
        
        public static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.loading, .loading):
                return true
            case (.success(let lhsResponse), .success(let rhsResponse)):
                return lhsResponse.token == rhsResponse.token
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
}
#endif
