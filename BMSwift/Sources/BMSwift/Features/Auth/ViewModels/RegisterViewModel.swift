#if canImport(SwiftUI) && os(iOS)
import Foundation
import SwiftUI

/// View model for handling user registration
@MainActor
public final class RegisterViewModel: ObservableObject {
    
    // MARK: - ViewState Definition
    public enum ViewState: Equatable {
        case idle
        case loading
        case success(AuthModels.RegisterResponse)
        case error(AuthModels.AuthError)
    }
    
    // MARK: - Published Properties
    
    /// Current state of the registration process
    @Published private(set) var state: ViewState = .idle
    
    /// Email input field
    @Published var email: String = ""
    
    /// Username input field
    @Published var username: String = ""
    
    /// Password input field
    @Published var password: String = ""
    
    /// Confirm password input field
    @Published var confirmPassword: String = ""
    
    // MARK: - Private Properties
    
    private let authService: AuthServiceProtocol
    
    // MARK: - Initialization
    
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
    
    public func validateInput() -> Bool {
        guard !email.isEmpty,
              !username.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {
            state = .error(AuthModels.AuthError.unknown("All fields are required"))
            return false
        }
        
        guard password == confirmPassword else {
            state = .error(AuthModels.AuthError.unknown("Passwords do not match"))
            return false
        }
        
        guard password.count >= 8 else {
            state = .error(AuthModels.AuthError.weakPassword)
            return false
        }
        
        return true
    }
    
    public func register() async {
        guard validateInput() else { return }
        
        state = .loading
        
        do {
            let response = try await authService.register(
                email: email,
                password: password,
                username: username
            )
            state = .success(response)
        } catch let error as AuthModels.AuthError {
            state = .error(error)
        } catch {
            state = .error(AuthModels.AuthError.unknown(error.localizedDescription))
        }
    }
    
    public func reset() {
        state = .idle
        email = ""
        username = ""
        password = ""
        confirmPassword = ""
    }
    
    // MARK: - Helper Properties
    
    public var errorMessage: String? {
        if case .error(let error) = state {
            return error.localizedDescription
        }
        return nil
    }
    
    public var isSuccess: Bool {
        if case .success = state {
            return true
        }
        return false
    }
    
    public var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }
}
#endif
