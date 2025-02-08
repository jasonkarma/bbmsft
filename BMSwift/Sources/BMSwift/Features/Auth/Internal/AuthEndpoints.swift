import Foundation


/// Authentication-related endpoints
public enum AuthEndpoints {
    // MARK: - Endpoint Definitions
    
    /// Login endpoint
    public struct Login: BMNetwork.APIEndpoint {
        // Types
        public typealias RequestType = AuthModels.LoginRequest
        public typealias ResponseType = AuthModels.LoginResponse
        
        // Required
        public let path: String = "/api/login"
        public let method: BMNetwork.HTTPMethod = .post
        
        // Optional overrides
        public var headers: [String: String] { ["Content-Type": "application/json"] }
        public var timeoutInterval: TimeInterval? { 30 }  // 30 second timeout for login
        
        public init() {}
    }
    
    /// Get current session endpoint
    public struct GetCurrentSession: BMNetwork.APIEndpoint {
        // Types
        public typealias RequestType = BMNetwork.EmptyRequest
        public typealias ResponseType = AuthModels.LoginResponse
        
        // Required
        public let path: String = "/api/getCurrentSession"
        public let method: BMNetwork.HTTPMethod = .get
        
        // Optional overrides
        public var headers: [String: String] {
            ["Content-Type": "application/json", "Authorization": "Bearer \(authToken)"]
        }
        public let authToken: String
        
        public init(authToken: String) {
            self.authToken = authToken
        }
    }
    
    /// Register endpoint
    public struct Register: BMNetwork.APIEndpoint {
        // Types
        public typealias RequestType = AuthModels.RegisterRequest
        public typealias ResponseType = AuthModels.RegisterResponse
        
        // Required
        public let path: String = "/api/register"
        public let method: BMNetwork.HTTPMethod = .post
        
        // Optional overrides
        public var headers: [String: String] { ["Content-Type": "application/json"] }
        public var timeoutInterval: TimeInterval? { 30 }
        
        public init() {}
    }
    
    /// Forgot password endpoint
    public struct ForgotPassword: BMNetwork.APIEndpoint {
        // Types
        public typealias RequestType = AuthModels.ForgotPasswordRequest
        public typealias ResponseType = AuthModels.ForgotPasswordResponse
        
        // Required
        public let path: String = "/api/password/email"
        public let method: BMNetwork.HTTPMethod = .post
        
        // Optional overrides
        public var headers: [String: String] { ["Content-Type": "application/json"] }
        
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
    /// Creates a login request
    static func login(email: String, password: String) -> BMNetwork.APIRequest<Login> {
        let endpoint = Login()
        let body = AuthModels.LoginRequest(email: email, password: password)
        return BMNetwork.APIRequest(endpoint: endpoint, body: body)
    }
    
    /// Creates a get current session request
    static func getCurrentSession(authToken: String? = nil) -> BMNetwork.APIRequest<GetCurrentSession> {
        let endpoint = GetCurrentSession(authToken: authToken ?? "")
        return BMNetwork.APIRequest(endpoint: endpoint)
    }
    
    /// Creates a registration request
    static func register(email: String, password: String, username: String) -> BMNetwork.APIRequest<Register> {
        let endpoint = Register()
        let body = AuthModels.RegisterRequest(email: email, password: password, username: username)
        return BMNetwork.APIRequest(endpoint: endpoint, body: body)
    }
    
    /// Creates a forgot password request
    static func forgotPassword(email: String) -> BMNetwork.APIRequest<ForgotPassword> {
        let endpoint = ForgotPassword()
        let body = AuthModels.ForgotPasswordRequest(email: email)
        return BMNetwork.APIRequest(endpoint: endpoint, body: body)
    }
}
