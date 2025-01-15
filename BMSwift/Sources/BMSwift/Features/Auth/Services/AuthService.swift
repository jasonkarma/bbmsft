import Foundation

/// Protocol defining the authentication service interface
public protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> AuthModels.LoginResponse
    func register(email: String, password: String, username: String) async throws -> AuthEndpoints.RegisterResponse
    func forgotPassword(email: String) async throws -> AuthEndpoints.ForgotPasswordResponse
    func getCurrentSession() async throws -> AuthModels.LoginResponse
}

/// Default implementation of AuthService
public final class AuthService: AuthServiceProtocol {
    // MARK: - Shared Instance
    public static let shared = AuthService(client: BMNetwork.NetworkClient(baseURL: URL(string: "https://wiki.kinglyrobot.com")!))
    
    // MARK: - Properties
    private let client: BMNetwork.NetworkClient
    
    // MARK: - Initialization
    public init(client: BMNetwork.NetworkClient) {
        self.client = client
    }
    
    // MARK: - AuthService Methods
    public func login(email: String, password: String) async throws -> AuthModels.LoginResponse {
        print("[Login] Making login request...")
        let request = AuthEndpoints.login(email: email, password: password)
        return try await client.send(request)
    }
    
    public func register(email: String, password: String, username: String) async throws -> AuthEndpoints.RegisterResponse {
        let request = AuthEndpoints.register(email: email, password: password, username: username)
        return try await client.send(request)
    }
    
    public func forgotPassword(email: String) async throws -> AuthEndpoints.ForgotPasswordResponse {
        let request = AuthEndpoints.forgotPassword(email: email)
        return try await client.send(request)
    }
    
    public func getCurrentSession() async throws -> AuthModels.LoginResponse {
        let request = AuthEndpoints.getCurrentSession()
        return try await client.send(request)
    }
}
