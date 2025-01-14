import Foundation

public actor AuthenticationActor {
    public static let shared = AuthenticationActor()
    
    private var token: String?
    private var expiresAt: Date?
    private let tokenKey = "auth.token"
    private let expiresKey = "auth.expires"
    
    private init() {
        // Load saved authentication state
        self.token = UserDefaults.standard.string(forKey: tokenKey)
        if let expiresString = UserDefaults.standard.string(forKey: expiresKey) {
            self.expiresAt = ISO8601DateFormatter().date(from: expiresString)
        }
    }
    
    public var isAuthenticated: Bool {
        guard let token = token, let expiresAt = expiresAt else {
            return false
        }
        return !token.isEmpty && expiresAt > Date()
    }
    
    public func getToken() -> String? {
        token
    }
    
    public func saveAuthentication(token: String, expiresAt: String) {
        self.token = token
        if let date = ISO8601DateFormatter().date(from: expiresAt) {
            self.expiresAt = date
        }
        
        // Persist authentication state
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(expiresAt, forKey: expiresKey)
    }
    
    public func clearAuthentication() {
        token = nil
        expiresAt = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: expiresKey)
    }
}
