import Foundation
import SwiftUI

@MainActor
public final class ProfileViewModel: ObservableObject {
    public enum ViewState {
        case idle
        case loading
        case loaded(ProfileResponse)
        case error(Error)
    }
    
    @Published private(set) var state: ViewState = .idle
    private let service: EncyclopediaService
    private let token: String
    
    public init(token: String, service: EncyclopediaService = EncyclopediaService(
        client: BMNetwork.NetworkClient(
            configuration: BMNetwork.Configuration(
                baseURL: URL(string: "https://wiki.kinglyrobot.com")!
            )
        )
    )) {
        self.token = token
        self.service = service
    }
    
    public func loadProfile() async {
        state = .loading
        
        do {
            let response = try await service.fetchProfile(token: token)
            state = .loaded(response)
        } catch {
            state = .error(error)
        }
    }
    
    public func logout() {
        // Clear the token
        TokenManager.shared.clearToken()
        
        // Reset state to idle
        state = .idle
        
        // Post notification for logout
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
}

extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}
