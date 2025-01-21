import Foundation

public actor AuthenticationActor {
    public static let shared = AuthenticationActor()
    
    private var token: String?
    private var expiresAt: Date?
    private let tokenKey = "auth.token"
    private let expiresKey = "auth.expires"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai") // Set to match server timezone
        return formatter
    }()
    
    private init() {
        // Load saved authentication state
        self.token = UserDefaults.standard.string(forKey: tokenKey)
        if let expiresString = UserDefaults.standard.string(forKey: expiresKey) {
            self.expiresAt = dateFormatter.date(from: expiresString)
        }
    }
    
    public var isAuthenticated: Bool {
        guard let token = token, let expiresAt = expiresAt else {
            return false
        }
        // Add some buffer time (e.g., 5 minutes) to prevent edge cases
        let now = Date()
        return !token.isEmpty && expiresAt.timeIntervalSince(now) > -300
    }
    
    public func getToken() -> String? {
        guard isAuthenticated else { return nil }
        return token
    }
    
    public func saveAuthentication(token: String, expiresAt: String) {
        print("Saving authentication - Token: \(token.prefix(10))..., Expires: \(expiresAt)")
        self.token = token
        if let date = dateFormatter.date(from: expiresAt) {
            print("Parsed expiration date: \(date)")
            self.expiresAt = date
        } else {
            print("Failed to parse expiration date: \(expiresAt)")
        }
        
        // Persist authentication state
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(expiresAt, forKey: expiresKey)
        UserDefaults.standard.synchronize()
    }
    
    public func clearAuthentication() {
        token = nil
        expiresAt = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: expiresKey)
    }
}
