#if canImport(SwiftUI) && os(iOS)
import Foundation
import Security

/// Errors that can occur during token operations
public enum TokenError: LocalizedError {
    case saveFailed(Error)
    case retrievalFailed(Error)
    case deletionFailed(Error)
    case invalidDate
    case expired
    case notFound
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "儲存憑證失敗: \(error.localizedDescription)"
        case .retrievalFailed(let error):
            return "取得憑證失敗: \(error.localizedDescription)"
        case .deletionFailed(let error):
            return "刪除憑證失敗: \(error.localizedDescription)"
        case .invalidDate:
            return "無效的憑證日期"
        case .expired:
            return "憑證已過期"
        case .notFound:
            return "找不到憑證"
        }
    }
}

/// Protocol defining token management functionality
public protocol TokenManagerProtocol {
    var isTokenValid: Bool { get }
    var isAuthenticated: Bool { get }
    func saveToken(_ token: String, expiry: String) throws
    func getToken() throws -> String
    func getTokenExpiry() throws -> Date
    func clearToken()
}

/// Manages authentication tokens securely using the Keychain
public class TokenManager: TokenManagerProtocol {
    public static let shared = TokenManager()
    
    private let tokenKey = "auth_token"
    private let expirationKey = "token_expiration"
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    /// Check if current token is valid and not expired
    public var isTokenValid: Bool {
        guard let token = try? getToken(),
              let expiry = try? getTokenExpiry(),
              !token.isEmpty else {
            return false
        }
        return expiry > Date()
    }
    
    /// Check if user is authenticated
    public var isAuthenticated: Bool {
        guard let token = try? getToken(),
              let _ = try? getTokenExpiry() else {
            return false
        }
        return !token.isEmpty
    }
    
    /// Save token and its expiry to the keychain
    /// - Parameters:
    ///   - token: The authentication token
    ///   - expiry: Token expiry date string
    public func saveToken(_ token: String, expiry: String) throws {
        userDefaults.set(token, forKey: tokenKey)
        userDefaults.set(expiry, forKey: expirationKey)
    }
    
    /// Retrieve the current token from keychain
    /// - Returns: The current authentication token
    /// - Throws: TokenError if token is not found or keychain error occurs
    public func getToken() throws -> String {
        guard let token = userDefaults.string(forKey: tokenKey) else {
            throw TokenError.notFound
        }
        return token
    }
    
    /// Retrieve the token expiry date
    /// - Returns: Token expiry date
    /// - Throws: TokenError if expiry is not found or invalid
    public func getTokenExpiry() throws -> Date {
        guard let expiry = userDefaults.string(forKey: expirationKey) else {
            throw TokenError.notFound
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let expiryDate = formatter.date(from: expiry) else {
            throw TokenError.invalidDate
        }
        
        return expiryDate
    }
    
    /// Remove token and expiry from keychain
    public func clearToken() {
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: expirationKey)
    }
}
#endif
