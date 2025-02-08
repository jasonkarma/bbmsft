import Foundation

/// Protocol defining the authentication service interface
public protocol AuthServiceProtocol {
    /// Attempts to log in a user with the provided credentials
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: LoginResponse containing the auth token and expiration
    /// - Throws: AuthModels.AuthError if login fails
    func login(email: String, password: String) async throws -> AuthModels.LoginResponse
    
    /// Registers a new user with the provided information
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    ///   - username: User's desired username
    /// - Returns: RegisterResponse containing the registration result
    /// - Throws: AuthModels.AuthError if registration fails
    func register(email: String, password: String, username: String) async throws -> AuthModels.RegisterResponse
    
    /// Initiates the password reset process for the provided email
    /// - Parameter email: Email address to reset password for
    /// - Returns: ForgotPasswordResponse indicating if the reset email was sent
    /// - Throws: AuthModels.AuthError if the request fails
    func forgotPassword(email: String) async throws -> AuthModels.ForgotPasswordResponse
    
    /// Retrieves the current user session if available
    /// - Returns: LoginResponse containing the current session
    /// - Throws: AuthModels.AuthError if no valid session exists
    func getCurrentSession() async throws -> AuthModels.LoginResponse
}

/// Implementation of the authentication service
public final class AuthService: AuthServiceProtocol {
    // MARK: - Properties
    
    private let client: BMNetwork.NetworkClient
    private let baseURL: URL
    
    // MARK: - Initialization
    
    /// Creates a new AuthService instance
    /// - Parameters:
    ///   - client: Network client to use for requests
    ///   - baseURL: Base URL for auth endpoints
    public init(
        client: BMNetwork.NetworkClient,
        baseURL: URL = URL(string: "https://wiki.kinglyrobot.com")!
    ) {
        self.client = client
        self.baseURL = baseURL
    }
    
    // MARK: - AuthServiceProtocol Methods
    
    public func login(email: String, password: String) async throws -> AuthModels.LoginResponse {
        do {
            let request = AuthEndpoints.login(email: email, password: password)
            return try await client.send(request)
        } catch let error as BMNetwork.APIError {
            switch error {
            case .unauthorized:
                throw AuthModels.AuthError.invalidCredentials
            case .networkError(let underlying):
                throw AuthModels.AuthError.networkError(underlying)
            default:
                throw AuthModels.AuthError.unknown(error.localizedDescription)
            }
        }
    }
    
    public func register(email: String, password: String, username: String) async throws -> AuthModels.RegisterResponse {
        do {
            let request = AuthEndpoints.register(email: email, password: password, username: username)
            return try await client.send(request)
        } catch let error as BMNetwork.APIError {
            switch error {
            case .serverError(let message) where message.contains("email"):
                throw AuthModels.AuthError.emailTaken
            case .networkError(let underlying):
                throw AuthModels.AuthError.networkError(underlying)
            default:
                throw AuthModels.AuthError.unknown(error.localizedDescription)
            }
        }
    }
    
    public func forgotPassword(email: String) async throws -> AuthModels.ForgotPasswordResponse {
        do {
            let request = AuthEndpoints.forgotPassword(email: email)
            return try await client.send(request)
        } catch let error as BMNetwork.APIError {
            switch error {
            case .notFound:
                throw AuthModels.AuthError.invalidEmail
            case .networkError(let underlying):
                throw AuthModels.AuthError.networkError(underlying)
            default:
                throw AuthModels.AuthError.unknown(error.localizedDescription)
            }
        }
    }
    
    public func getCurrentSession() async throws -> AuthModels.LoginResponse {
        do {
            let request = AuthEndpoints.getCurrentSession()
            return try await client.send(request)
        } catch let error as BMNetwork.APIError {
            switch error {
            case .unauthorized:
                throw AuthModels.AuthError.invalidCredentials
            case .networkError(let underlying):
                throw AuthModels.AuthError.networkError(underlying)
            default:
                throw AuthModels.AuthError.unknown(error.localizedDescription)
            }
        }
    }
}
