#if canImport(SwiftUI) && os(iOS)
import Foundation
import KeychainAccess

/// Errors that can occur during token operations
public enum TokenError: LocalizedError {
    case tokenNotFound
    case invalidToken
    case tokenExpired
    case keychainError(Error)
    case invalidDateFormat
    
    public var errorDescription: String? {
        switch self {
        case .tokenNotFound:
            return "找不到登入憑證"
        case .invalidToken:
            return "登入憑證無效"
        case .tokenExpired:
            return "登入憑證已過期"
        case .keychainError(let error):
            return "金鑰鏈錯誤: \(error.localizedDescription)"
        case .invalidDateFormat:
            return "日期格式無效"
        }
    }
}

/// Protocol defining token management functionality
public protocol TokenManagerProtocol {
    func saveToken(_ token: String, expiry: String) throws
    func getToken() throws -> String
    func getTokenExpiry() throws -> Date
    func clearToken() throws
    var isTokenValid: Bool { get }
    func refreshTokenIfNeeded(threshold: TimeInterval) async throws -> Bool
}

/// Manages authentication tokens securely using the Keychain
public final class TokenManager: TokenManagerProtocol {
    public static let shared = TokenManager()
    
    private let keychain: Keychain
    private let tokenKey = "com.bmswift.userToken"
    private let tokenExpiryKey = "com.bmswift.tokenExpiry"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private init() {
        self.keychain = Keychain(service: "com.bmswift.tokenservice")
    }
    
    /// Save token and its expiry to the keychain
    /// - Parameters:
    ///   - token: The authentication token
    ///   - expiry: Token expiry date string
    public func saveToken(_ token: String, expiry: String) throws {
        try keychain.set(token, key: tokenKey)
        try keychain.set(expiry, key: tokenExpiryKey)
    }
    
    /// Retrieve the current token from keychain
    /// - Returns: The current authentication token
    /// - Throws: TokenError if token is not found or keychain error occurs
    public func getToken() throws -> String {
        guard let token = try keychain.get(tokenKey) else {
            throw TokenError.tokenNotFound
        }
        return token
    }
    
    /// Retrieve the token expiry date
    /// - Returns: Token expiry date
    /// - Throws: TokenError if expiry is not found or invalid
    public func getTokenExpiry() throws -> Date {
        guard let expiryString = try keychain.get(tokenExpiryKey) else {
            throw TokenError.tokenNotFound
        }
        
        // Try ISO8601 format first
        if let date = ISO8601DateFormatter().date(from: expiryString) {
            return date
        }
        
        // Try our custom format
        if let date = dateFormatter.date(from: expiryString) {
            return date
        }
        
        throw TokenError.invalidDateFormat
    }
    
    /// Remove token and expiry from keychain
    public func clearToken() throws {
        try keychain.remove(tokenKey)
        try keychain.remove(tokenExpiryKey)
    }
    
    /// Check if current token is valid and not expired
    public var isTokenValid: Bool {
        do {
            let expiry = try getTokenExpiry()
            return expiry > Date()
        } catch {
            return false
        }
    }
    
    /// Refresh token if it's about to expire
    /// - Parameter threshold: Time threshold before expiry to trigger refresh
    /// - Returns: True if token was refreshed, false otherwise
    public func refreshTokenIfNeeded(threshold: TimeInterval) async throws -> Bool {
        guard isTokenValid else {
            throw TokenError.tokenExpired
        }
        
        let expiry = try getTokenExpiry()
        let shouldRefresh = expiry.timeIntervalSinceNow < threshold
        
        if shouldRefresh {
            // TODO: Implement token refresh logic
            // For now, just return false since we don't have refresh endpoint
            return false
        }
        
        return false
    }
}
#endif
