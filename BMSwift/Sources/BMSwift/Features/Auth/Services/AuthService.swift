import Foundation

/// Protocol defining the authentication service interface
public protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> AuthModels.LoginResponse
    func register(email: String, password: String, username: String) async throws -> AuthModels.RegisterResponse
    func verifyEmail(token: String) async throws -> AuthModels.VerifyEmailResponse
    func resetPassword(token: String, newPassword: String) async throws -> AuthModels.ResetPasswordResponse
    func forgotPassword(email: String) async throws -> AuthModels.ForgotPasswordResponse
}

/// Default implementation of AuthService
public final class AuthService: AuthServiceProtocol {
    // MARK: - Properties
    private let client: BMNetwork.NetworkClient
    
    // MARK: - Initialization
    public init(client: BMNetwork.NetworkClient) {
        self.client = client
    }
    
    // MARK: - AuthService Methods
    public func login(email: String, password: String) async throws -> AuthModels.LoginResponse {
        let request = AuthEndpoints.login(email: email, password: password)
        return try await client.send(request)
    }
    
    public func register(email: String, password: String, username: String) async throws -> AuthModels.RegisterResponse {
        let request = AuthEndpoints.register(email: email, password: password, username: username)
        return try await client.send(request)
    }
    
    public func verifyEmail(token: String) async throws -> AuthModels.VerifyEmailResponse {
        let request = AuthEndpoints.verifyEmail(token: token)
        return try await client.send(request)
    }
    
    public func resetPassword(token: String, newPassword: String) async throws -> AuthModels.ResetPasswordResponse {
        let request = AuthEndpoints.resetPassword(token: token, newPassword: newPassword)
        return try await client.send(request)
    }
    
    public func forgotPassword(email: String) async throws -> AuthModels.ForgotPasswordResponse {
        let request = AuthEndpoints.forgotPassword(email: email)
        return try await client.send(request)
    }
}
