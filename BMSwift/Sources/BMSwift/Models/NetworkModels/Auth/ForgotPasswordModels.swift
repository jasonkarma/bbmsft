import Foundation

public struct ForgotPasswordRequest: Encodable {
    public let email: String
    public let locale: String
    public let env: String
    
    public init(email: String, locale: String = "zh_TW", env: String = "") {
        self.email = email
        self.locale = locale
        self.env = env
    }
}

public struct ForgotPasswordResponse: Decodable {
    public let message: String?
    public let count: Int?
    public let createdAt: String?
    public let expiredAt: String?
    public let error: String?
    
    private enum CodingKeys: String, CodingKey {
        case message
        case count
        case createdAt = "created_at"
        case expiredAt = "expired_at"
        case error
    }
}
