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

/// Manages authentication tokens securely using the Keychain
public class TokenManager: TokenManagerProtocol {
    public static let shared = TokenManager()
    
    private let keychain: Keychain
    private let tokenKey = "auth_token"
    
    private init() {
        self.keychain = Keychain(service: "com.bbmsft.BMSwiftApp")
            .accessibility(.whenUnlocked)
    }
    
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
        do {
            try keychain.set(token, key: tokenKey)
        } catch {
            print("Failed to save token: \(error)")
        }
    }
    
    public func getToken() throws -> String {
        do {
            guard let token = try keychain.get(tokenKey) else {
                throw TokenError.notFound
            }
            return token
        } catch let error as KeychainAccess.Status {
            throw TokenError.retrievalFailed(error)
        }
    }
    
    public func clearToken() {
        do {
            try keychain.remove(tokenKey)
        } catch {
            print("Failed to clear token: \(error)")
        }
    }
}
#endif
