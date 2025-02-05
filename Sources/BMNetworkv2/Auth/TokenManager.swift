import Foundation
import Security

extension BMNetworkV2 {
    public enum TokenError: LocalizedError {
        case saveFailed(Error)
        case retrievalFailed(Error)
        case deletionFailed(Error)
        case tokenNotFound
        case invalidToken
        
        public var errorDescription: String? {
            switch self {
            case .saveFailed(let error):
                return "無法儲存登入資訊: \(error.localizedDescription)"
            case .retrievalFailed(let error):
                return "無法取得登入資訊: \(error.localizedDescription)"
            case .deletionFailed(let error):
                return "無法刪除登入資訊: \(error.localizedDescription)"
            case .tokenNotFound:
                return "找不到登入資訊"
            case .invalidToken:
                return "登入資訊無效"
            }
        }
    }
    
    public protocol TokenManagerProtocol {
        var isAuthenticated: Bool { get }
        func saveToken(_ token: String)
        func getToken() throws -> String
        func clearToken()
    }
    
    public final class TokenManager: TokenManagerProtocol {
        private let service = "com.kinglyrobot.bmswift"
        private let account = "auth-token"
        
        public static let shared = TokenManager()
        
        private init() {}
        
        public var isAuthenticated: Bool {
            (try? getToken()) != nil
        }
        
        public func saveToken(_ token: String) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: token.data(using: .utf8)!
            ]
            
            // First attempt to delete any existing token
            SecItemDelete(query as CFDictionary)
            
            // Then save the new token
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                print("Error saving token: \(status)")
                return
            }
        }
        
        public func getToken() throws -> String {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecReturnData as String: true
            ]
            
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            
            guard status == errSecSuccess,
                  let data = result as? Data,
                  let token = String(data: data, encoding: .utf8)
            else {
                throw TokenError.tokenNotFound
            }
            
            return token
        }
        
        public func clearToken() {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            
            SecItemDelete(query as CFDictionary)
        }
    }
}
