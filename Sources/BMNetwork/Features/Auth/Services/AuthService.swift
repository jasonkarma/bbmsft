import Foundation

/// Protocol defining the authentication service interface
public protocol AuthServiceProtocol {
    /// Login with email and password
    func login(email: String, password: String) async throws -> AuthModels.LoginResponse
    
    /// Register a new user
    func register(email: String, password: String, username: String) async throws -> AuthModels.RegisterResponse
    
    /// Request password reset
    func forgotPassword(email: String) async throws -> AuthModels.ForgotPasswordResponse
    
    /// Get current session information
    func getCurrentSession() async throws -> AuthModels.LoginResponse
    
    /// Check if user is authenticated
    var isAuthenticated: Bool { get async }
}

/// Default implementation of AuthService
public final class AuthService: AuthServiceProtocol {
    // MARK: - Shared Instance
    public static let shared = AuthService()
    
    // MARK: - Properties
    private let client: BMNetworkcl.NetworkClient
    private let authActor: AuthenticationActor
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai") // Match server timezone
        return formatter
    }()
    
    // MARK: - Initialization
    public init(client: BMNetworkcl.NetworkClient = .shared,
                authActor: AuthenticationActor = .shared) {
        self.client = client
        self.authActor = authActor
    }
    
    // MARK: - AuthService Methods
    public func login(email: String, password: String) async throws -> AuthModels.LoginResponse {
        let request = BMNetwork.APIRequest(endpoint: AuthEndpoints.Login(), body: AuthModels.LoginRequest(email: email, password: password))
        let response = try await client.send(request)
        
        // Format expiration date
        let expirationDate = response.expiresAt ?? Calendar.current.date(byAdding: .hour, value: 24, to: Date())!
        let expirationString = dateFormatter.string(from: expirationDate)
        
        // Save authentication
        await authActor.saveAuthentication(token: response.token, expiresAt: expirationString)
        
        return response
    }
    
    public func register(email: String, password: String, username: String) async throws -> AuthModels.RegisterResponse {
        let request = AuthEndpoints.register(email: email, password: password, username: username)
        return try await client.send(request)
    }
    
    public func forgotPassword(email: String) async throws -> AuthModels.ForgotPasswordResponse {
        let request = AuthEndpoints.forgotPassword(email: email)
        return try await client.send(request)
    }
    
    public func getCurrentSession() async throws -> AuthModels.LoginResponse {
        let request = AuthEndpoints.getCurrentSession()
        return try await client.send(request)
    }
    
    public var isAuthenticated: Bool {
        get async {
            await authActor.isAuthenticated
        }
    }
}
