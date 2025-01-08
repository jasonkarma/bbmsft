#if canImport(SwiftUI) && os(iOS)
import Foundation

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
    public let expiredAt: String
    public let firstLogin: Bool
    
    private enum CodingKeys: String, CodingKey {
        case token
        case expiredAt = "expired_at"
        case firstLogin = "first_login"
    }
    
    public init(token: String, expiredAt: String, firstLogin: Bool) {
        self.token = token
        self.expiredAt = expiredAt
        self.firstLogin = firstLogin
    }
}

public struct LoginError: Codable {
    public let error: String
    
    public init(error: String) {
        self.error = error
    }
}
#endif
