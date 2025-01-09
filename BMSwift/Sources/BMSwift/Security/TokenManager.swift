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
    func saveToken(_ token: String, expiry: String) throws
    func getToken() throws -> String
    func getTokenExpiry() throws -> Date
    func clearToken() throws
}

/// Manages authentication tokens securely using the Keychain
public class TokenManager: TokenManagerProtocol {
    public static let shared = TokenManager()
    
    private let tokenKey = "com.bmswift.userToken"
    private let expiryKey = "com.bmswift.tokenExpiry"
    
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
    
    /// Save token and its expiry to the keychain
    /// - Parameters:
    ///   - token: The authentication token
    ///   - expiry: Token expiry date string
    public func saveToken(_ token: String, expiry: String) throws {
        print(" Saving token with expiry: \(expiry)")
        
        // Parse the date
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let expiryDate = formatter.date(from: expiry) else {
            print(" Failed to parse date: \(expiry)")
            throw TokenError.invalidDate
        }
        
        print(" Successfully parsed date: \(expiryDate)")
        
        // Save token
        let tokenQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: token.data(using: .utf8)!
        ]
        
        // Save expiry
        let expiryQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: expiryKey,
            kSecValueData as String: expiryDate.timeIntervalSince1970.description.data(using: .utf8)!
        ]
        
        // First try to delete any existing items
        SecItemDelete(tokenQuery as CFDictionary)
        SecItemDelete(expiryQuery as CFDictionary)
        
        // Then add new items
        let tokenStatus = SecItemAdd(tokenQuery as CFDictionary, nil)
        let expiryStatus = SecItemAdd(expiryQuery as CFDictionary, nil)
        
        if tokenStatus != errSecSuccess || expiryStatus != errSecSuccess {
            print(" Failed to save token or expiry")
            throw TokenError.saveFailed(NSError(domain: "TokenManager", code: -1))
        }
        
        print(" Token and expiry saved successfully")
    }
    
    /// Retrieve the current token from keychain
    /// - Returns: The current authentication token
    /// - Throws: TokenError if token is not found or keychain error occurs
    public func getToken() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw TokenError.notFound
        }
        
        return token
    }
    
    /// Retrieve the token expiry date
    /// - Returns: Token expiry date
    /// - Throws: TokenError if expiry is not found or invalid
    public func getTokenExpiry() throws -> Date {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: expiryKey,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let timeString = String(data: data, encoding: .utf8),
              let timeInterval = TimeInterval(timeString) else {
            throw TokenError.notFound
        }
        
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    /// Remove token and expiry from keychain
    public func clearToken() throws {
        let tokenQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        let expiryQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: expiryKey
        ]
        
        let tokenStatus = SecItemDelete(tokenQuery as CFDictionary)
        let expiryStatus = SecItemDelete(expiryQuery as CFDictionary)
        
        if tokenStatus != errSecSuccess && tokenStatus != errSecItemNotFound {
            throw TokenError.deletionFailed(NSError(domain: "TokenManager", code: Int(tokenStatus)))
        }
        
        if expiryStatus != errSecSuccess && expiryStatus != errSecItemNotFound {
            throw TokenError.deletionFailed(NSError(domain: "TokenManager", code: Int(expiryStatus)))
        }
    }
}
#endif
