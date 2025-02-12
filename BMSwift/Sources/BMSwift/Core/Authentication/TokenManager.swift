#if canImport(SwiftUI) && os(iOS)
import Foundation
import KeychainAccess

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

/// Manages authentication tokens securely using both Keychain and UserDefaults
public class TokenManager: TokenManagerProtocol {
    public static let shared = TokenManager()
    
    private let keychain: Keychain
    private let tokenKey = "BMSwiftApp.authToken"
    private let userDefaultsTokenKey = "BMSwiftApp.userDefaultsAuthToken"
    private let defaults = UserDefaults.standard
    
    private init() {
        print("🔑 [TokenManager] Initializing...")
        
        self.keychain = Keychain(service: "com.bbmsft.BMSwiftApp")
            .accessibility(.afterFirstUnlock)
        
        // Debug: Check existing tokens
        if let token = defaults.string(forKey: userDefaultsTokenKey) {
            print("🔑 [TokenManager] Found token in UserDefaults: \(token.prefix(10))...")
        }
        
        if let token = try? keychain.get(tokenKey) {
            print("🔑 [TokenManager] Found token in Keychain: \(token.prefix(10))...")
        }
    }
    
    public var isTokenValid: Bool {
        print("🔑 [TokenManager] Checking token validity")
        
        // First check UserDefaults
        if let storedToken = defaults.string(forKey: userDefaultsTokenKey), !storedToken.isEmpty {
            print("🔑 [TokenManager] Found valid token in UserDefaults")
            return true
        }
        
        // Then check Keychain
        do {
            let _ = try getToken()
            print("🔑 [TokenManager] Found valid token in Keychain")
            return true
        } catch {
            print("🔑 [TokenManager] No valid token found")
            return false
        }
    }
    
    public var isAuthenticated: Bool {
        let auth = isTokenValid
        print("🔑 [TokenManager] isAuthenticated: \(auth)")
        return auth
    }
    
    public var token: String? {
        // First try UserDefaults
        if let token = defaults.string(forKey: userDefaultsTokenKey) {
            print("🔑 [TokenManager] Retrieved token from UserDefaults")
            return token
        }
        
        // Then try Keychain
        do {
            let token = try getToken()
            print("🔑 [TokenManager] Retrieved token from Keychain")
            return token
        } catch {
            print("🔑 [TokenManager] Failed to get token: \(error.localizedDescription)")
            return nil
        }
    }
    
    public func saveToken(_ token: String) {
        print("🔑 [TokenManager] Saving token: \(token.prefix(10))...")
        
        // Save to UserDefaults
        defaults.set(token, forKey: userDefaultsTokenKey)
        defaults.synchronize()
        print("🔑 [TokenManager] Token saved to UserDefaults")
        
        // Save to Keychain
        do {
            try keychain.set(token, key: tokenKey)
            print("🔑 [TokenManager] Token saved to Keychain")
        } catch {
            print("🔑 [TokenManager] Failed to save to Keychain: \(error)")
        }
        
        // Verify the saves
        if let savedUserDefaultsToken = defaults.string(forKey: userDefaultsTokenKey) {
            print("🔑 [TokenManager] Verified UserDefaults token: \(savedUserDefaultsToken.prefix(10))...")
        }
        
        if let savedKeychainToken = try? keychain.get(tokenKey) {
            print("🔑 [TokenManager] Verified Keychain token: \(savedKeychainToken.prefix(10))...")
        }
    }
    
    public func getToken() throws -> String {
        print("🔑 [TokenManager] Attempting to get token")
        
        // First try UserDefaults
        if let token = defaults.string(forKey: userDefaultsTokenKey) {
            print("🔑 [TokenManager] Found token in UserDefaults")
            return token
        }
        
        // Then try Keychain
        do {
            guard let token = try keychain.get(tokenKey) else {
                print("🔑 [TokenManager] No token found in Keychain")
                throw TokenError.notFound
            }
            print("🔑 [TokenManager] Found token in Keychain")
            return token
        } catch let error as KeychainAccess.Status {
            print("🔑 [TokenManager] Keychain error: \(error)")
            throw TokenError.retrievalFailed(error)
        }
    }
    
    public func clearToken() {
        print("🔑 [TokenManager] Clearing tokens")
        
        // Clear UserDefaults
        defaults.removeObject(forKey: userDefaultsTokenKey)
        defaults.synchronize()
        print("🔑 [TokenManager] Cleared UserDefaults token")
        
        // Clear Keychain
        do {
            try keychain.remove(tokenKey)
            print("🔑 [TokenManager] Cleared Keychain token")
        } catch {
            print("🔑 [TokenManager] Failed to clear Keychain token: \(error)")
        }
    }
}
#endif
