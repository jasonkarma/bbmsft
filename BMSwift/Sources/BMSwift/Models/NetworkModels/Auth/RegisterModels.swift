import Foundation

public struct RegisterRequest: Codable {
    public let email: String
    public let username: String
    public let password: String
    public let from: String = "beauty_app"
    
    public init(email: String, username: String, password: String) {
        self.email = email
        self.username = username
        self.password = password
    }
}

public struct RegisterResponse: Codable {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}

public struct RegisterError: Codable {
    public let error: [String]
    
    public init(error: [String]) {
        self.error = error
    }
}
