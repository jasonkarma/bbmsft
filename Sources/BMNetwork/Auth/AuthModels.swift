import Foundation

extension BMNetworkV2 {
    // MARK: - Login Models
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
        public let expiresAt: Date
        public let firstLogin: Bool
        
        public init(token: String, expiresAt: Date, firstLogin: Bool) {
            self.token = token
            self.expiresAt = expiresAt
            self.firstLogin = firstLogin
        }
    }
    
    // MARK: - Register Models
    public struct RegisterRequest: Codable {
        public let email: String
        public let username: String
        public let password: String
        public let from: String
        
        public init(email: String, username: String, password: String, from: String = "ios") {
            self.email = email
            self.username = username
            self.password = password
            self.from = from
        }
    }
    
    public struct MessageResponse: Codable {
        public let message: String
        
        public init(message: String) {
            self.message = message
        }
    }
    
    // MARK: - Forgot Password Models
    public struct ForgotPasswordRequest: Codable {
        public let email: String
        public let locale: String
        public let env: String
        
        public init(email: String, locale: String = "zh-TW", env: String = "production") {
            self.email = email
            self.locale = locale
            self.env = env
        }
    }
    
    public struct ForgotPasswordResponse: Codable {
        public let message: String
        public let count: Int
        public let createdAt: String
        public let expiredAt: String
        
        public init(message: String, count: Int, createdAt: String, expiredAt: String) {
            self.message = message
            self.count = count
            self.createdAt = createdAt
            self.expiredAt = expiredAt
        }
    }
}
