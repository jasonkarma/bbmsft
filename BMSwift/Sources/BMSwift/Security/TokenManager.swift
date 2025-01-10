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
    var token: String? { get }
    func saveToken(_ token: String)
    func getToken() throws -> String
    func clearToken()
}

/// Manages authentication tokens securely using the Keychain
public class TokenManager: TokenManagerProtocol {
    public static let shared = TokenManager()
    
    private let tokenKey = "auth_token"
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    public var isTokenValid: Bool {
        do {
            _ = try getToken()
            return true
        } catch {
            return false
        }
    }
    
    public var isAuthenticated: Bool {
        isTokenValid
    }
    
    public var token: String? {
        try? getToken()
    }
    
    public func saveToken(_ token: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: token.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // First try to delete any existing token
        SecItemDelete(query as CFDictionary)
        
        // Then save the new token
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Failed to save token with status: \(status)")
        }
    }
    
    public func getToken() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8)
        else {
            throw TokenError.notFound
        }
        
        return token
    }
    
    public func clearToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
#endif
