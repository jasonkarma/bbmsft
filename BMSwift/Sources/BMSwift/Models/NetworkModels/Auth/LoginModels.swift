#if canImport(SwiftUI) && os(iOS)
import Foundation

public struct LoginRequest: Codable {
    public let email: String
    public let password: String
    
    private enum CodingKeys: String, CodingKey {
        case email
        case password
    }
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct LoginResponse: Codable {
    public let token: String
    public let expiresAt: String
    public let firstLogin: Bool
    
    private enum CodingKeys: String, CodingKey {
        case token
        case expiresAt = "expires_at"
        case firstLogin = "first_login"
    }
    
    public init(token: String, expiresAt: String, firstLogin: Bool) {
        self.token = token
        self.expiresAt = expiresAt
        self.firstLogin = firstLogin
    }
}

public struct LoginError: Codable {
    public let error: String
    
    private enum CodingKeys: String, CodingKey {
        case error
    }
    
    public init(error: String) {
        self.error = error
    }
}
#endif
