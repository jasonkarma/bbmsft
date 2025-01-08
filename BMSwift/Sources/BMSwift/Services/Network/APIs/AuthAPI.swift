#if canImport(SwiftUI) && os(iOS)
import Foundation

/// BMSwift - Authentication API
/// Handles all authentication-related network requests
///
/// Dependencies:
/// - NetworkService: For making HTTP requests
@available(iOS 15.0, *)
public enum AuthAPI {
    private static let baseURL = "https://wiki.kinglyrobot.com/api"
    
    public static func login(email: String, password: String) async throws -> LoginResponse {
        let request = APIRequest<LoginRequest, LoginResponse>(
            endpoint: "\(baseURL)/login",
            method: .post,
            body: LoginRequest(email: email, password: password)
        )
        return try await NetworkService.shared.request(request)
    }
    
    public static func signup(email: String, password: String) async throws -> SignupResponse {
        let request = APIRequest<SignupRequest, SignupResponse>(
            endpoint: "\(baseURL)/signup",
            method: .post,
            body: SignupRequest(email: email, password: password)
        )
        return try await NetworkService.shared.request(request)
    }
}
#endif
