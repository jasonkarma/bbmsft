#if canImport(UIKit) && os(iOS)
import Foundation

public protocol ImgurTokenManaging {
    func getValidToken() async throws -> String
    func refreshTokenIfNeeded() async throws
}

public actor ImgurTokenManager: ImgurTokenManaging {
    private var currentToken: String
    private let refreshToken: String
    private let clientId: String
    private let clientSecret: String
    private var tokenExpiration: Date
    
    public init() {
        self.currentToken = ImgurConfig.accessToken
        self.refreshToken = ImgurConfig.refreshToken
        self.clientId = ImgurConfig.clientId
        self.clientSecret = ImgurConfig.clientSecret
        // Set initial expiration based on the token's expires_in value
        self.tokenExpiration = Date(timeIntervalSince1970: TimeInterval(315360000))
    }
    
    public func getValidToken() async throws -> String {
        if Date() >= tokenExpiration {
            try await refreshTokenIfNeeded()
        }
        return currentToken
    }
    
    public func refreshTokenIfNeeded() async throws {
        guard Date() >= tokenExpiration else { return }
        
        var request = URLRequest(url: URL(string: ImgurConfig.authURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "refresh_token": refreshToken,
            "client_id": clientId,
            "client_secret": clientSecret,
            "grant_type": "refresh_token"
        ]
        
        let bodyString = body.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImgurTokenError.refreshFailed
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        self.currentToken = tokenResponse.accessToken
        self.tokenExpiration = Date(timeIntervalSinceNow: TimeInterval(tokenResponse.expiresIn))
    }
}

private struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

public enum ImgurTokenError: LocalizedError {
    case refreshFailed
    
    public var errorDescription: String? {
        switch self {
        case .refreshFailed:
            return "Failed to refresh Imgur access token"
        }
    }
}
#endif
