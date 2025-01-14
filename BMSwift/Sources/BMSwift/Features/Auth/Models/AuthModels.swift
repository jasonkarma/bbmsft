import Foundation

/// Namespace for Auth-related models
public enum AuthModels {
    // MARK: - Login
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
        public let firstLogin: Bool
        
        public init(token: String, firstLogin: Bool) {
            self.token = token
            self.firstLogin = firstLogin
        }
    }
    
    // MARK: - Register
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
        
        public init(token: String) {
            self.token = token
        }
    }
    
    // MARK: - Verify Email
    public struct VerifyEmailRequest: Codable {
        public let token: String
        
        public init(token: String) {
            self.token = token
        }
    }
    
    public struct VerifyEmailResponse: Codable {
        public let verified: Bool
        
        public init(verified: Bool) {
            self.verified = verified
        }
    }
    
    // MARK: - Reset Password
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
    
    // MARK: - Forgot Password
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
}
