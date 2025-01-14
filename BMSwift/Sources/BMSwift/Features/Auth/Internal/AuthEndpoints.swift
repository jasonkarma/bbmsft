import Foundation
// swiftlint:disable nesting
// swiftlint:disable redundant_public_modifier
// MARK: - Auth Endpoints
public enum AuthEndpoints {
    // MARK: - Login
    public struct Login: APIEndpoint {
        public typealias RequestType = AuthEndpoints.LoginRequest
        public typealias ResponseType = AuthEndpoints.LoginResponse
        
        public let path: String = "/api/login"
        public let method: HTTPMethod = .post
        public let requiresAuth: Bool = false
    }
    
    // MARK: - Register
    public struct Register: APIEndpoint {
        public typealias RequestType = AuthEndpoints.RegisterRequest
        public typealias ResponseType = AuthEndpoints.RegisterResponse
        
        public let path: String = "/api/register"
        public let method: HTTPMethod = .post
        public let requiresAuth: Bool = false
    }
    
    // MARK: - Verify Email
    public struct VerifyEmail: APIEndpoint {
        public typealias RequestType = AuthEndpoints.VerifyEmailRequest
        public typealias ResponseType = AuthEndpoints.VerifyEmailResponse
        
        public let path: String = "/api/verify-email"
        public let method: HTTPMethod = .post
        public let requiresAuth: Bool = false
    }
    
    // MARK: - Reset Password
    public struct ResetPassword: APIEndpoint {
        public typealias RequestType = AuthEndpoints.ResetPasswordRequest
        public typealias ResponseType = AuthEndpoints.ResetPasswordResponse
        
        public let path: String = "/api/reset-password"
        public let method: HTTPMethod = .post
        public let requiresAuth: Bool = false
    }
    
    // MARK: - Forgot Password
    public struct ForgotPassword: APIEndpoint {
        public typealias RequestType = AuthEndpoints.ForgotPasswordRequest
        public typealias ResponseType = AuthEndpoints.ForgotPasswordResponse
        
        public let path: String = "/api/forgot-password"
        public let method: HTTPMethod = .post
        public let requiresAuth: Bool = false
    }
}

// MARK: - Factory Methods
public extension AuthEndpoints {
    static func login(email: String, password: String) -> APIRequest<Login> {
        let request = AuthEndpoints.LoginRequest(email: email, password: password)
        return APIRequest(endpoint: Login(), body: request)
    }
    
    static func register(request: AuthEndpoints.RegisterRequest) -> APIRequest<Register> {
        APIRequest(endpoint: Register(), body: request)
    }
    
    static func verifyEmail(request: AuthEndpoints.VerifyEmailRequest) -> APIRequest<VerifyEmail> {
        APIRequest(endpoint: VerifyEmail(), body: request)
    }
    
    static func resetPassword(request: AuthEndpoints.ResetPasswordRequest) -> APIRequest<ResetPassword> {
        APIRequest(endpoint: ResetPassword(), body: request)
    }
    
    static func forgotPassword(request: AuthEndpoints.ForgotPasswordRequest) -> APIRequest<ForgotPassword> {
        APIRequest(endpoint: ForgotPassword(), body: request)
    }
}

// MARK: - Request/Response Types
public extension AuthEndpoints {
    public struct LoginRequest: Codable {
        public let email: String
        public let password: String
        
        public init(email: String, password: String) {
            self.email = email
            self.password = password
        }
    }
    
    public struct LoginResponse: Codable {
        public let token: String
        public let user: User
        
        public init(token: String, user: User) {
            self.token = token
            self.user = user
        }
    }
    
    public struct RegisterRequest: Codable {
        public let email: String
        public let password: String
        public let username: String
        
        public init(email: String, password: String, username: String) {
            self.email = email
            self.password = password
            self.username = username
        }
    }
    
    public struct RegisterResponse: Codable {
        public let token: String
        public let user: User
        
        public init(token: String, user: User) {
            self.token = token
            self.user = user
        }
    }
    
    public struct VerifyEmailRequest: Codable {
        public let token: String
        
        public init(token: String) {
            self.token = token
        }
    }
    
    public struct VerifyEmailResponse: Codable {
        public let success: Bool
        
        public init(success: Bool) {
            self.success = success
        }
    }
    
    public struct ResetPasswordRequest: Codable {
        public let token: String
        public let newPassword: String
        
        public init(token: String, newPassword: String) {
            self.token = token
            self.newPassword = newPassword
        }
    }
    
    public struct ResetPasswordResponse: Codable {
        public let success: Bool
        
        public init(success: Bool) {
            self.success = success
        }
    }
    
    public struct ForgotPasswordRequest: Codable {
        public let email: String
        
        public init(email: String) {
            self.email = email
        }
    }
    
    public struct ForgotPasswordResponse: Codable {
        public let success: Bool
        
        public init(success: Bool) {
            self.success = success
        }
    }
    
    public struct User: Codable {
        public let id: String
        public let email: String
        public let username: String
        
        public init(id: String, email: String, username: String) {
            self.id = id
            self.email = email
            self.username = username
        }
    }
}
