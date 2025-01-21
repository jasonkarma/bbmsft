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
        public let expiresAt: Date?
        public let firstLogin: Bool
        
        private enum CodingKeys: String, CodingKey {
            case token
            case expiresAt = "expires_at"
            case firstLogin = "first_login"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            token = try container.decode(String.self, forKey: .token)
            firstLogin = try container.decodeIfPresent(Bool.self, forKey: .firstLogin) ?? false
            
            // Handle optional expires_at
            if let expiresAtString = try container.decodeIfPresent(String.self, forKey: .expiresAt) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
                
                if let date = formatter.date(from: expiresAtString) {
                    self.expiresAt = date
                } else {
                    self.expiresAt = nil
                }
            } else {
                self.expiresAt = nil
            }
        }
        
        public init(token: String, expiresAt: Date? = nil, firstLogin: Bool = false) {
            self.token = token
            self.expiresAt = expiresAt
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
        public let message: String
        
        public init(token: String, message: String = "Registration successful") {
            self.token = token
            self.message = message
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
