import SwiftUI

@MainActor
public class RootViewModel: ObservableObject {
    @Published public private(set) var isAuthenticated: Bool = false
    public let tokenManager: TokenManagerProtocol
    
    public init(tokenManager: TokenManagerProtocol = TokenManager.shared) {
        print("🔐 [RootViewModel] ====== INITIALIZING ======")
        self.tokenManager = tokenManager
        checkAuthenticationStatus()
        
        // Listen for login success
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginSuccess),
            name: .userDidLogin,
            object: nil
        )
        print("🔐 [RootViewModel] ====== INITIALIZED ======")
    }
    
    private func checkAuthenticationStatus() {
        print("🔐 [RootViewModel] ====== CHECKING AUTH STATUS ======")
        let token = tokenManager.token
        print("🔐 [RootViewModel] Token: \(token != nil ? "EXISTS" : "NOT FOUND")")
        
        if tokenManager.isAuthenticated {
            print("🔐 [RootViewModel] ====== AUTH STATUS: AUTHENTICATED ======")
            isAuthenticated = true
        } else {
            print("🔐 [RootViewModel] ====== AUTH STATUS: NOT AUTHENTICATED ======")
            isAuthenticated = false
        }
    }
    
    @objc private func handleLoginSuccess() {
        print("🔐 [RootViewModel] ====== LOGIN SUCCESS ======")
        checkAuthenticationStatus()
    }
    
    public func handleLogout() {
        print("🔐 [RootViewModel] ====== HANDLING LOGOUT ======")
        tokenManager.clearToken()
        isAuthenticated = false
    }
    
    public func refreshAuthStatus() {
        print("🔐 [RootViewModel] ====== REFRESHING AUTH STATUS ======")
        checkAuthenticationStatus()
    }
}

public struct RootView: View {
    @StateObject public var viewModel = RootViewModel()
    @State private var isEncyclopediaPresented = true
    
    public init() {
        print("📱 [RootView] ====== VIEW INITIALIZED ======")
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                if viewModel.isAuthenticated {
                    EncyclopediaView(isPresented: $isEncyclopediaPresented, token: viewModel.tokenManager.token ?? "")
                        .ignoresSafeArea()
                        .onAppear {
                            print("📱 [RootView] ====== SHOWING ENCYCLOPEDIA VIEW ======")
                        }
                } else {
                    LoginView()
                        .ignoresSafeArea()
                        .onAppear {
                            print("📱 [RootView] ====== SHOWING LOGIN VIEW ======")
                        }
                }
            }
            .onAppear {
                print("📱 [RootView] ====== VIEW APPEARED ======")
                viewModel.refreshAuthStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
                viewModel.handleLogout()
            }
        }
    }
}

extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
}
