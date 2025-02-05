import Foundation

/// Protocol for handling authentication state
public protocol AuthenticationHandler {
    /// Get the current authentication token
    func getToken() async throws -> String?
    
    /// Handle authentication error
    /// - Parameter error: The error that occurred
    /// - Returns: True if the error was handled and the request should be retried
    func handleAuthenticationError(_ error: Error) async -> Bool
    
    /// Clear any stored authentication state
    func clearAuthentication()
}

/// Default implementation of AuthenticationHandler
public final class DefaultAuthenticationHandler: AuthenticationHandler {
    private let tokenManager: TokenManager
    private let tokenRefresher: TokenRefresher
    
    public init(
        tokenManager: TokenManager = .shared,
        tokenRefresher: TokenRefresher = DefaultTokenRefresher()
    ) {
        self.tokenManager = tokenManager
        self.tokenRefresher = tokenRefresher
    }
    
    public func getToken() async throws -> String? {
        // First try to get existing token
        if let token = tokenManager.getToken() {
            return token
        }
        
        // If no token, try to refresh
        return try await tokenRefresher.refreshToken()
    }
    
    public func handleAuthenticationError(_ error: Error) async -> Bool {
        guard let apiError = error as? APIError,
              apiError == .unauthorized else {
            return false
        }
        
        // Clear existing token
        tokenManager.clearToken()
        
        // Try to refresh token
        do {
            _ = try await tokenRefresher.refreshToken()
            return true // Retry the request
        } catch {
            return false // Unable to refresh, don't retry
        }
    }
    
    public func clearAuthentication() {
        tokenManager.clearToken()
    }
}

/// Protocol for refreshing authentication tokens
public protocol TokenRefresher {
    /// Refresh the authentication token
    /// - Returns: The new token if successful
    func refreshToken() async throws -> String?
}

/// Default implementation of TokenRefresher
public final class DefaultTokenRefresher: TokenRefresher {
    private let tokenManager: TokenManager
    
    public init(tokenManager: TokenManager = .shared) {
        self.tokenManager = tokenManager
    }
    
    public func refreshToken() async throws -> String? {
        // TODO: Implement token refresh logic
        // This would typically involve making a network request to refresh the token
        // For now, just return nil to indicate no token available
        return nil
    }
}
