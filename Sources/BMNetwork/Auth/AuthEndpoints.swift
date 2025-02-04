import Foundation

import Foundation

extension BMNetworkV2.Auth {
    /// Authentication-related endpoints and models
    public enum Endpoints: FeatureTypeRegistry {
        public static var featureId: String { "auth" }
        public static var featureNamespace: String { featureId }
        
        public static func register() {
            try? TypeRegistry.shared.register(LoginRequest.self, in: featureId)
            try? TypeRegistry.shared.register(LoginResponse.self, in: featureId)
            try? TypeRegistry.shared.register(RegisterRequest.self, in: featureId)
            try? TypeRegistry.shared.register(RegisterResponse.self, in: featureId)
            try? TypeRegistry.shared.register(ForgotPasswordRequest.self, in: featureId)
            try? TypeRegistry.shared.register(ForgotPasswordResponse.self, in: featureId)
        }
        // MARK: - Models
        
        /// Request model for login endpoint
        public struct LoginRequest: TypeSafeModel {
            public let email: String
            public let password: String
            
            public init(email: String, password: String) {
                self.email = email
                self.password = password
            }
        }
        
        /// Response model for login and session endpoints
        public struct LoginResponse: TypeSafeModel {
            public let token: String
            public let expiresAt: Date
            public let firstLogin: Bool
            
            private enum CodingKeys: String, CodingKey {
                case token
                case expiresAt = "expires_at"
                case firstLogin = "first_login"
            }
            
            public init(from decoder: Decoder) throws {
                struct TempLoginResponse: Codable {
                    let token: String
                    let expires_at: String
                    let first_login: Bool
                }
                
                let temp = try TempLoginResponse(from: decoder)
                self.token = temp.token
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
                
                guard let date = formatter.date(from: temp.expires_at) else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: [CodingKeys.expiresAt],
                        debugDescription: "Date string does not match expected format: \(temp.expires_at)"
                    ))
                }
                
                self.expiresAt = date
                self.firstLogin = temp.first_login
            }
        }
        
        /// Request model for registration endpoint
        public struct RegisterRequest: TypeSafeModel {
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
        }
        
        /// Response model for registration endpoint
        public struct RegisterResponse: TypeSafeModel {
            public let message: String
        }
        
        /// Request model for forgot password endpoint
        public struct ForgotPasswordRequest: TypeSafeModel {
            public let email: String
            public let locale: String
            public let env: String
            
            public init(email: String, locale: String = "zh-TW", env: String = "") {
                self.email = email
                self.locale = locale
                self.env = env
            }
        }
        
        /// Response model for forgot password endpoint
        public struct ForgotPasswordResponse: TypeSafeModel {
            public let message: String
            public let count: Int
            public let createdAt: String
            public let expiredAt: String
        }
        
        // MARK: - Endpoints
        
        /// Login endpoint
        public struct Login: APIEndpoint {
            public typealias RequestType = LoginRequest
            public typealias ResponseType = LoginResponse
            
            public var baseURL: URL {
                URL(string: "https://wiki.kinglyrobot.com")!
            }
            public let path: String = "/api/login"
            public let method: HTTPMethod = .post
            public let requiresAuth: Bool = false
            
            public init() {}
        }
        
        /// Get current session endpoint
        public struct CurrentSession: APIEndpoint {
            public typealias RequestType = EmptyRequest
            public typealias ResponseType = LoginResponse
            
            public var baseURL: URL {
                URL(string: "https://wiki.kinglyrobot.com")!
            }
            public let path: String = "/api/session"
            public let method: HTTPMethod = .get
            public let requiresAuth: Bool = true
            
            public init() {}
        }
        
        /// Register endpoint
        public struct Register: APIEndpoint {
            public typealias RequestType = RegisterRequest
            public typealias ResponseType = RegisterResponse
            
            public var baseURL: URL {
                URL(string: "https://wiki.kinglyrobot.com")!
            }
            public let path: String = "/api/register"
            public let method: HTTPMethod = .post
            public let requiresAuth: Bool = false
            
            public init() {}
        }
        
        /// Forgot password endpoint
        public struct ForgotPassword: APIEndpoint {
            public typealias RequestType = ForgotPasswordRequest
            public typealias ResponseType = ForgotPasswordResponse
            
            public var baseURL: URL {
                URL(string: "https://wiki.kinglyrobot.com")!
            }
            public let path: String = "/api/password/email"
            public let method: HTTPMethod = .post
            public let requiresAuth: Bool = false
            
            public init() {}
        }
    }
}
