import Foundation

/// Namespace for Auth-related API endpoints
public enum AuthEndpoints {
    // MARK: - Login
    public struct Login: BMNetworkAPIEndpoint {
        public typealias RequestType = AuthModels.LoginRequest
        public typealias ResponseType = AuthModels.LoginResponse
        
        public let path: String = "/api/login"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        
        public init() {}
    }
    
    // MARK: - Register
    public struct Register: BMNetworkAPIEndpoint {
        public typealias RequestType = AuthModels.RegisterRequest
        public typealias ResponseType = AuthModels.RegisterResponse
        
        public let path: String = "/api/register"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        
        public init() {}
    }
    
    // MARK: - Verify Email
    public struct VerifyEmail: BMNetworkAPIEndpoint {
        public typealias RequestType = AuthModels.VerifyEmailRequest
        public typealias ResponseType = AuthModels.VerifyEmailResponse
        
        public let path: String = "/api/verify-email"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        
        public init() {}
    }
    
    // MARK: - Reset Password
    public struct ResetPassword: BMNetworkAPIEndpoint {
        public typealias RequestType = AuthModels.ResetPasswordRequest
        public typealias ResponseType = AuthModels.ResetPasswordResponse
        
        public let path: String = "/api/reset-password"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        
        public init() {}
    }
    
    // MARK: - Forgot Password
    public struct ForgotPassword: BMNetworkAPIEndpoint {
        public typealias RequestType = AuthModels.ForgotPasswordRequest
        public typealias ResponseType = AuthModels.ForgotPasswordResponse
        
        public let path: String = "/api/forgot-password"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        
        public init() {}
    }
}

// MARK: - Factory Methods
public extension AuthEndpoints {
    static func login(email: String, password: String) -> BMNetworkAPIRequest<Login> {
        let request = AuthModels.LoginRequest(email: email, password: password)
        return BMNetworkAPIRequest(endpoint: Login(), body: request)
    }
    
    static func register(email: String, password: String, username: String) -> BMNetworkAPIRequest<Register> {
        let request = AuthModels.RegisterRequest(email: email, password: password, username: username)
        return BMNetworkAPIRequest(endpoint: Register(), body: request)
    }
    
    static func verifyEmail(token: String) -> BMNetworkAPIRequest<VerifyEmail> {
        let request = AuthModels.VerifyEmailRequest(token: token)
        return BMNetworkAPIRequest(endpoint: VerifyEmail(), body: request)
    }
    
    static func resetPassword(token: String, newPassword: String) -> BMNetworkAPIRequest<ResetPassword> {
        let request = AuthModels.ResetPasswordRequest(token: token, newPassword: newPassword)
        return BMNetworkAPIRequest(endpoint: ResetPassword(), body: request)
    }
    
    static func forgotPassword(email: String) -> BMNetworkAPIRequest<ForgotPassword> {
        let request = AuthModels.ForgotPasswordRequest(email: email)
        return BMNetworkAPIRequest(endpoint: ForgotPassword(), body: request)
    }
}
