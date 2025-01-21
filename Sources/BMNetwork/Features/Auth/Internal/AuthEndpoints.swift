import Foundation

/// Authentication-related endpoints
public enum AuthEndpoints {
    /// Login endpoint
    public struct Login: BMNetwork.APIEndpoint {
        public typealias RequestType = AuthModels.LoginRequest
        public typealias ResponseType = AuthModels.LoginResponse
        
        public let path: String = "/api/login"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        
        public init() {}
    }
    
    /// Get current session endpoint
    public struct GetCurrentSession: BMNetwork.APIEndpoint {
        public typealias RequestType = BMNetwork.EmptyRequest?
        public typealias ResponseType = AuthModels.LoginResponse
        
        public let path: String = "/api/getCurrentSession"
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = true
        
        public init() {}
    }
    
    /// Register endpoint
    public struct Register: BMNetwork.APIEndpoint {
        public typealias RequestType = AuthModels.RegisterRequest
        public typealias ResponseType = AuthModels.RegisterResponse
        
        public let path: String = "/api/register"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        
        public init() {}
    }
    
    /// Forgot password endpoint
    public struct ForgotPassword: BMNetwork.APIEndpoint {
        public typealias RequestType = AuthModels.ForgotPasswordRequest
        public typealias ResponseType = AuthModels.ForgotPasswordResponse
        
        public let path: String = "/api/forgotPassword"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        
        public init() {}
    }
    
    /// Empty request type for endpoints that don't need a request body
    public struct EmptyRequest: Codable {
        public init() {}
    }
    
    // MARK: - Request/Response Models
    // Removed models as they are now in AuthModels namespace
    
    // MARK: - Factory Methods
    public static func login(email: String, password: String) -> BMNetwork.APIRequest<Login> {
        let endpoint = Login()
        let body = AuthModels.LoginRequest(email: email, password: password)
        return BMNetwork.APIRequest(endpoint: endpoint, body: body)
    }
    
    public static func register(email: String, password: String, username: String) -> BMNetwork.APIRequest<Register> {
        let endpoint = Register()
        let body = AuthModels.RegisterRequest(email: email, password: password, username: username)
        return BMNetwork.APIRequest(endpoint: endpoint, body: body)
    }
    
    public static func forgotPassword(email: String) -> BMNetwork.APIRequest<ForgotPassword> {
        let endpoint = ForgotPassword()
        let body = AuthModels.ForgotPasswordRequest(email: email)
        return BMNetwork.APIRequest(endpoint: endpoint, body: body)
    }
    
    public static func getCurrentSession() -> BMNetwork.APIRequest<GetCurrentSession> {
        let endpoint = GetCurrentSession()
        return BMNetwork.APIRequest(endpoint: endpoint, body: nil)
    }
}
