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
        public typealias RequestType = EmptyRequest
        public typealias ResponseType = AuthModels.LoginResponse
        
        public let path: String = "/api/session"
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = true
        
        public init() {}
    }
    
    /// Register endpoint
    public struct Register: BMNetwork.APIEndpoint {
        public typealias RequestType = RegisterRequest
        public typealias ResponseType = RegisterResponse
        
        public let path: String = "/api/register"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        
        public init() {}
    }
    
    /// Forgot password endpoint
    public struct ForgotPassword: BMNetwork.APIEndpoint {
        public typealias RequestType = ForgotPasswordRequest
        public typealias ResponseType = ForgotPasswordResponse
        
        public let path: String = "/api/password/email"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        
        public init() {}
    }
    
    /// Empty request type for endpoints that don't need a request body
    public struct EmptyRequest: Codable {
        public init() {}
    }
}

// MARK: - Request/Response Models
public extension AuthEndpoints {
    struct RegisterRequest: Codable {
        public let email: String
        public let username: String
        public let password: String
        public let from: String
        
        public init(email: String, username: String, password: String, from: String = "beauty_app") {
            self.email = email
            self.username = username
            self.password = password
            self.from = from
        }
        
        enum CodingKeys: String, CodingKey {
            case email
            case username
            case password
            case from
        }
    }
    
    struct RegisterResponse: Codable {
        public let message: String
        
        public init(message: String) {
            self.message = message
        }
        
        enum CodingKeys: String, CodingKey {
            case message
        }
    }
    
    struct ForgotPasswordRequest: Codable {
        public let email: String
        public let locale: String
        public let env: String
        
        public init(email: String, locale: String = "zh-TW", env: String = "") {
            self.email = email
            self.locale = locale
            self.env = env
        }
        
        enum CodingKeys: String, CodingKey {
            case email
            case locale
            case env
        }
    }
    
    struct ForgotPasswordResponse: Codable {
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
        
        enum CodingKeys: String, CodingKey {
            case message
            case count
            case createdAt = "created_at"
            case expiredAt = "expired_at"
        }
    }
}

// MARK: - Factory Methods
public extension AuthEndpoints {
    static func login(email: String, password: String) -> BMNetwork.APIRequest<Login> {
        let request = Login()
        let body = AuthModels.LoginRequest(email: email, password: password)
        return BMNetwork.APIRequest(endpoint: request, body: body)
    }
    
    static func register(email: String, password: String, username: String) -> BMNetwork.APIRequest<Register> {
        let request = RegisterRequest(email: email, username: username, password: password)
        return BMNetwork.APIRequest(endpoint: Register(), body: request)
    }
    
    static func forgotPassword(email: String) -> BMNetwork.APIRequest<ForgotPassword> {
        let request = ForgotPasswordRequest(email: email)
        return BMNetwork.APIRequest(endpoint: ForgotPassword(), body: request)
    }
    
    static func getCurrentSession() -> BMNetwork.APIRequest<GetCurrentSession> {
        let request = GetCurrentSession()
        let body = EmptyRequest()
        return BMNetwork.APIRequest(endpoint: request, body: body)
    }
}
