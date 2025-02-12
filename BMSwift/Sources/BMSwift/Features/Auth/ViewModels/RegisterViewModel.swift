#if canImport(SwiftUI) && os(iOS)
import Foundation
import SwiftUI

/// View model for handling user registration
@MainActor
public final class RegisterViewModel: ObservableObject {
    
    // MARK: - ViewState Definition
    public enum ViewState: Equatable {
        case idle
        case loading
        case success(AuthEndpoints.RegisterResponse)
        case error(String)
        
        public static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.loading, .loading):
                return true
            case (.success(let lhsResponse), .success(let rhsResponse)):
                return lhsResponse.message == rhsResponse.message && lhsResponse.error == rhsResponse.error
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    // MARK: - Published Properties
    
    /// Current state of the registration process
    @Published private(set) var state: ViewState = .idle
    
    /// Email input field
    @Published var email: String = ""
    
    /// Username input field
    @Published var username: String = ""
    
    /// Password input field
    @Published var password: String = ""
    
    /// Confirm password input field
    @Published var confirmPassword: String = ""
    
    // MARK: - Private Properties
    
    private let authService: AuthServiceProtocol
    
    // MARK: - Initialization
    
    public init(authService: AuthServiceProtocol = AuthService(
        client: BMNetwork.NetworkClient(
            configuration: BMNetwork.Configuration(
                baseURL: URL(string: "https://wiki.kinglyrobot.com")!
            )
        )
    )) {
        self.authService = authService
    }
    
    // MARK: - Public Methods
    
    public func validateInput() -> Bool {
        guard !email.isEmpty else {
            state = .error("請輸入電郵地址")
            return false
        }
        
        guard !username.isEmpty else {
            state = .error("請輸入用戶名稱")
            return false
        }
        
        guard !password.isEmpty else {
            state = .error("請輸入密碼")
            return false
        }
        
        guard !confirmPassword.isEmpty else {
            state = .error("請確認密碼")
            return false
        }
        
        guard password == confirmPassword else {
            state = .error("密碼不一致")
            return false
        }
        
        guard password.count >= 8 else {
            state = .error("密碼長度至少需要8個字符")
            return false
        }
        
        return true
    }
    
    public func register() async {
        guard validateInput() else { return }
        
        state = .loading
        
        do {
            let response = try await authService.register(
                email: email,
                password: password,
                username: username,
                from: "beauty_app"
            )
            
            if let error = response.error?.first {
                state = .error(error)
            } else if response.message != nil {
                state = .success(response)
            } else {
                state = .error("註冊失敗，請稍後再試")
            }
        } catch {
            state = .error("註冊失敗，請稍後再試")
        }
    }
    
    public func reset() {
        state = .idle
        email = ""
        username = ""
        password = ""
        confirmPassword = ""
    }
    
    // MARK: - Helper Properties
    
    public var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }
}
#endif
