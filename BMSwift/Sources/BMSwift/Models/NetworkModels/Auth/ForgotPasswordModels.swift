#if canImport(Foundation)
import Foundation

public struct ForgotPasswordRequest: Codable {
    public let email: String
    
    public init(email: String) {
        self.email = email
    }
}

public struct ForgotPasswordResponse: Codable {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}
#endif
