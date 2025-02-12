import Foundation

/// Namespace for Auth-related models and types
public enum AuthModels {
    // MARK: - Request Types
    
    /// Login request model
    public struct LoginRequest: Codable {
        public let email: String
        public let password: String
        
        public init(email: String, password: String) {
            self.email = email
            self.password = password
        }
    }
    
    /// Registration request model
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
    
    /// Forgot password request model
    public struct ForgotPasswordRequest: Codable {
        public let email: String
        public let locale: String
        public let env: String
        public let from: String
        
        public init(
            email: String,
            locale: String = "zh-TW",
            env: String = "",
            from: String = "beauty"
        ) {
            self.email = email
            self.locale = locale
            self.env = env
            self.from = from
        }
    }
    
    /// Verify email request model
    public struct VerifyEmailRequest: Codable {
        public let token: String
        
        public init(token: String) {
            self.token = token
        }
    }
    
    /// Reset password request model
    public struct ResetPasswordRequest: Codable {
        public let token: String
        public let newPassword: String
        
        public init(token: String, newPassword: String) {
            self.token = token
            self.newPassword = newPassword
        }
    }
    
    // MARK: - Response Types
    
    /// Login response model
    public struct LoginResponse: Codable, Equatable {
        /// Authentication token
        public let token: String
        
        /// Token expiration date
        public let expiresAt: Date
        
        /// Indicates if this is the user's first login
        public let firstLogin: Bool
        
        private enum CodingKeys: String, CodingKey {
            case token
            case expiresAt = "expires_at"
            case firstLogin = "first_login"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Decode basic properties
            token = try container.decode(String.self, forKey: .token)
            firstLogin = try container.decode(Bool.self, forKey: .firstLogin)
            
            // Handle date decoding
            let dateString = try container.decode(String.self, forKey: .expiresAt)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
            
            guard let date = formatter.date(from: dateString) else {
                throw AuthError.invalidDateFormat(dateString)
            }
            
            expiresAt = date
        }
        
        public static func == (lhs: LoginResponse, rhs: LoginResponse) -> Bool {
            return lhs.token == rhs.token && lhs.expiresAt == rhs.expiresAt && lhs.firstLogin == rhs.firstLogin
        }
    }
    
    /// Registration response model
    public struct RegisterResponse: Codable, Equatable {
        public let message: String
        public let userId: Int
        
        private enum CodingKeys: String, CodingKey {
            case message
            case userId = "user_id"
        }
        
        public static func == (lhs: RegisterResponse, rhs: RegisterResponse) -> Bool {
            return lhs.message == rhs.message && lhs.userId == rhs.userId
        }
    }
    
    /// Forgot password response model
    public struct ForgotPasswordResponse: Codable, Equatable {
        public let message: String
        public let count: Int
        public let createdAt: String
        public let expiredAt: String
        
        private enum CodingKeys: String, CodingKey {
            case message
            case count
            case createdAt = "created_at"
            case expiredAt = "expired_at"
        }
        
        public static func == (lhs: ForgotPasswordResponse, rhs: ForgotPasswordResponse) -> Bool {
            return lhs.message == rhs.message && 
                   lhs.count == rhs.count &&
                   lhs.createdAt == rhs.createdAt &&
                   lhs.expiredAt == rhs.expiredAt
        }
    }
    
    /// Verify email response model
    public struct VerifyEmailResponse: Codable {
        public let verified: Bool
        
        public init(verified: Bool) {
            self.verified = verified
        }
    }
    
    /// Reset password response model
    public struct ResetPasswordResponse: Codable {
        public let success: Bool
        
        public init(success: Bool) {
            self.success = success
        }
    }
    
    // MARK: - Error Types
    
    /// Auth-specific error types
    public enum AuthError: LocalizedError, Equatable {
        case invalidCredentials
        case accountLocked
        case emailTaken
        case invalidEmail
        case weakPassword
        case invalidDateFormat(String)
        case networkError(Error)
        case unknown(String)
        
        public var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Invalid email or password"
            case .accountLocked:
                return "Your account has been locked. Please contact support."
            case .emailTaken:
                return "This email is already registered"
            case .invalidEmail:
                return "Please enter a valid email address"
            case .weakPassword:
                return "Password is too weak. It must be at least 8 characters long and include numbers and special characters."
            case .invalidDateFormat(let dateString):
                return "Server returned invalid date format: \(dateString)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .unknown(let message):
                return message
            }
        }
        
        public static func == (lhs: AuthError, rhs: AuthError) -> Bool {
            switch (lhs, rhs) {
            case (.invalidCredentials, .invalidCredentials),
                 (.accountLocked, .accountLocked),
                 (.emailTaken, .emailTaken),
                 (.invalidEmail, .invalidEmail),
                 (.weakPassword, .weakPassword):
                return true
            case (.invalidDateFormat(let lhsString), .invalidDateFormat(let rhsString)):
                return lhsString == rhsString
            case (.unknown(let lhsMessage), .unknown(let rhsMessage)):
                return lhsMessage == rhsMessage
            case (.networkError(let lhsError), .networkError(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
}
