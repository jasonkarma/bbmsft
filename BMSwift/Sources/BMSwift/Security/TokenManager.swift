#if canImport(SwiftUI) && os(iOS)
import Foundation
import KeychainAccess

/// Errors that can occur during token operations
public enum TokenError: LocalizedError {
    case tokenNotFound
    case invalidToken
    case tokenExpired
    case keychainError(Error)
    
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
}

/// Manages authentication tokens securely using the Keychain
public final class TokenManager: TokenManagerProtocol {
    public static let shared = TokenManager()
    
    private let keychain: Keychain
    private let tokenKey = "com.bmswift.userToken"
    private let tokenExpiryKey = "com.bmswift.tokenExpiry"
    
    private init() {
        self.keychain = Keychain(service: "com.bmswift.tokenservice")
        logDebug("TokenManager initialized")
    }
    
    /// Save token and its expiry to the keychain
    /// - Parameters:
    ///   - token: The authentication token
    ///   - expiry: Token expiry date string
    public func saveToken(_ token: String, expiry: String) throws {
        logInfo("Saving token to keychain")
        do {
            try keychain
                .accessibility(.whenUnlockedThisDeviceOnly)
                .set(token, key: tokenKey)
            
            try keychain
                .accessibility(.whenUnlockedThisDeviceOnly)
                .set(expiry, key: tokenExpiryKey)
            
            logDebug("Token and expiry saved successfully")
        } catch {
            logError("Failed to save token: \(error.localizedDescription)")
            throw TokenError.keychainError(error)
        }
    }
    
    /// Retrieve the current token from keychain
    /// - Returns: The current authentication token
    /// - Throws: TokenError if token is not found or keychain error occurs
    public func getToken() throws -> String {
        logDebug("Retrieving token from keychain")
        guard let token = try? keychain.get(tokenKey) else {
            logWarning("Token not found in keychain")
            throw TokenError.tokenNotFound
        }
        return token
    }
    
    /// Retrieve the token expiry date
    /// - Returns: Token expiry date
    /// - Throws: TokenError if expiry is not found or invalid
    public func getTokenExpiry() throws -> Date {
        logDebug("Retrieving token expiry from keychain")
        guard let expiryString = try? keychain.get(tokenExpiryKey),
              let expiryDate = ISO8601DateFormatter().date(from: expiryString) else {
            logWarning("Token expiry not found or invalid")
            throw TokenError.invalidToken
        }
        return expiryDate
    }
    
    /// Remove token and expiry from keychain
    public func clearToken() throws {
        logInfo("Clearing token from keychain")
        do {
            try keychain.remove(tokenKey)
            try keychain.remove(tokenExpiryKey)
            logDebug("Token cleared successfully")
        } catch {
            logError("Failed to clear token: \(error.localizedDescription)")
            throw TokenError.keychainError(error)
        }
    }
    
    /// Check if current token is valid and not expired
    public var isTokenValid: Bool {
        guard let token = try? getToken(),
              let expiry = try? getTokenExpiry(),
              !token.isEmpty,
              expiry > Date() else {
            return false
        }
        return true
    }
}

/// Extension to handle common token operations
public extension TokenManager {
    /// Refresh token if it's about to expire
    /// - Parameter threshold: Time threshold before expiry to trigger refresh (default 1 hour)
    /// - Returns: True if token was refreshed, false otherwise
    func refreshTokenIfNeeded(threshold: TimeInterval = 3600) async throws -> Bool {
        guard isTokenValid else { return false }
        
        let expiry = try getTokenExpiry()
        let shouldRefresh = expiry.timeIntervalSinceNow < threshold
        
        if shouldRefresh {
            logInfo("Token approaching expiry, initiating refresh")
            // Implement token refresh logic here
            // This would typically call your refresh token API
            return true
        }
        
        return false
    }
}
#endif
