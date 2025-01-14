import Foundation

extension BMAuth {
    public protocol ServiceProtocol {
        func login(email: String, password: String) async throws -> AuthEndpoints.LoginResponse
        func register(email: String, password: String, username: String) async throws -> AuthEndpoints.RegisterResponse
        func verifyEmail(token: String) async throws -> AuthEndpoints.VerifyEmailResponse
        func resetPassword(token: String, newPassword: String) async throws -> AuthEndpoints.ResetPasswordResponse
        func forgotPassword(email: String) async throws -> AuthEndpoints.ForgotPasswordResponse
    }
    
    public final class Service: ServiceProtocol {
        // MARK: - Properties
        public let client: NetworkClient
        
        // MARK: - Initialization
        public init(client: NetworkClient) {
            self.client = client
        }
        
        // MARK: - Auth Methods
        public func login(email: String, password: String) async throws -> AuthEndpoints.LoginResponse {
            let request = AuthEndpoints.login(email: email, password: password)
            return try await client.send(request)
        }
        
        public func register(email: String, password: String, username: String) async throws -> AuthEndpoints.RegisterResponse {
            let request = AuthEndpoints.RegisterRequest(email: email, password: password, username: username)
            let apiRequest = AuthEndpoints.register(request: request)
            return try await client.send(apiRequest)
        }
        
        public func verifyEmail(token: String) async throws -> AuthEndpoints.VerifyEmailResponse {
            let request = AuthEndpoints.VerifyEmailRequest(token: token)
            let apiRequest = AuthEndpoints.verifyEmail(request: request)
            return try await client.send(apiRequest)
        }
        
        public func resetPassword(token: String, newPassword: String) async throws -> AuthEndpoints.ResetPasswordResponse {
            let request = AuthEndpoints.ResetPasswordRequest(token: token, newPassword: newPassword)
            let apiRequest = AuthEndpoints.resetPassword(request: request)
            return try await client.send(apiRequest)
        }
        
        public func forgotPassword(email: String) async throws -> AuthEndpoints.ForgotPasswordResponse {
            let request = AuthEndpoints.ForgotPasswordRequest(email: email)
            let apiRequest = AuthEndpoints.forgotPassword(request: request)
            return try await client.send(apiRequest)
        }
    }
}
