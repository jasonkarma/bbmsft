import Foundation

// MARK: - Auth Namespace
public enum BMAuth {
    // MARK: - Login Models
    public struct LoginRequest: Encodable {
        public let email: String
        public let password: String
        
        public init(email: String, password: String) {
            self.email = email
            self.password = password
        }
    }
    
    public struct LoginResponse: Decodable {
        public let token: String
        public let expiresAt: Date
        public let firstLogin: Bool
        
        private enum CodingKeys: String, CodingKey {
            case token
            case expiresAt = "expired_at"
            case firstLogin = "first_login"
        }
    }
    
    // MARK: - Register Models
    public struct RegisterRequest: Encodable {
        public let username: String
        public let email: String
        public let password: String
        public let from: String
        
        public init(username: String, email: String, password: String, from: String) {
            self.username = username
            self.email = email
            self.password = password
            self.from = from
        }
    }
    
    public struct RegisterResponse: Decodable {
        public let message: String
        public let errors: [String]?
        
        private enum CodingKeys: String, CodingKey {
            case message
            case errors = "error"
        }
    }
    
    // MARK: - Forgot Password Models
    public struct ForgotPasswordRequest: Encodable {
        public let email: String
        public let locale: String
        public let env: String
        
        public init(email: String, locale: String, env: String) {
            self.email = email
            self.locale = locale
            self.env = env
        }
    }
    
    public struct ForgotPasswordResponse: Decodable {
        public let message: String
        public let count: Int?
        public let createdAt: Date?
        public let expiresAt: Date?
        public let error: String?
        
        private enum CodingKeys: String, CodingKey {
            case message
            case count
            case createdAt = "created_at"
            case expiresAt = "expired_at"
            case error
        }
    }
}
