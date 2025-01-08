import Foundation

#if os(iOS)
import SwiftUI
import BMSwift

@main
struct BMSwiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
#endif
