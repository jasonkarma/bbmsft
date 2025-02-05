import Foundation

/// Protocol for authentication service
public protocol AuthServiceProtocol {
    /// Login with email and password
    func login(email: String, password: String) async throws -> AuthEndpoints.LoginResponse
    
    /// Get current session information
    func getCurrentSession() async throws -> AuthEndpoints.LoginResponse
    
    /// Register a new user
    func register(email: String, username: String, password: String) async throws -> AuthEndpoints.RegisterResponse
    
    /// Request password reset email
    func forgotPassword(email: String) async throws -> AuthEndpoints.ForgotPasswordResponse
}

/// Authentication service implementation
public final class AuthService: AuthServiceProtocol {
    // MARK: - Properties
    
    private let client: BMNetworkV2.NetworkClientProtocol
    private let tokenManager: TokenManagerProtocol
    
    // MARK: - Initialization
    
    public init(
        client: BMNetworkV2.NetworkClientProtocol,
        tokenManager: TokenManagerProtocol
    ) {
        self.client = client
        self.tokenManager = tokenManager
    }
    
    // MARK: - AuthServiceProtocol Implementation
    
    public func login(email: String, password: String) async throws -> AuthEndpoints.LoginResponse {
        // Validate namespace access
        try BMNetworkV2.RuntimeChecks.validateAccess(
            to: AuthEndpoints.Login(),
            from: AuthEndpoints.featureNamespace
        )
        
        let endpoint = AuthEndpoints.Login()
        let request = AuthEndpoints.LoginRequest(email: email, password: password)
        
        // Use explicit auth for login
        let response = try await client.sendWithExplicitAuth(endpoint, body: request, token: nil)
        
        // Save token on successful login
        try await tokenManager.saveToken(response.token)
        return response
    }
    
    public func getCurrentSession() async throws -> AuthEndpoints.LoginResponse {
        // Validate namespace access
        try BMNetworkV2.RuntimeChecks.validateAccess(
            to: AuthEndpoints.CurrentSession(),
            from: AuthEndpoints.featureNamespace
        )
        
        let endpoint = AuthEndpoints.CurrentSession()
        return try await client.send(endpoint, body: AuthEndpoints.EmptyRequest())
    }
    
    public func register(email: String, username: String, password: String) async throws -> AuthEndpoints.RegisterResponse {
        // Validate namespace access
        try BMNetworkV2.RuntimeChecks.validateAccess(
            to: AuthEndpoints.Register(),
            from: AuthEndpoints.featureNamespace
        )
        
        let endpoint = AuthEndpoints.Register()
        let request = AuthEndpoints.RegisterRequest(
            email: email,
            username: username,
            password: password
        )
        
        return try await client.send(endpoint, body: request)
    }
    
    public func forgotPassword(email: String) async throws -> AuthEndpoints.ForgotPasswordResponse {
        // Validate namespace access
        try BMNetworkV2.RuntimeChecks.validateAccess(
            to: AuthEndpoints.ForgotPassword(),
            from: AuthEndpoints.featureNamespace
        )
        
        let endpoint = AuthEndpoints.ForgotPassword()
        let request = AuthEndpoints.ForgotPasswordRequest(email: email)
        
        return try await client.send(endpoint, body: request)
    }
}
