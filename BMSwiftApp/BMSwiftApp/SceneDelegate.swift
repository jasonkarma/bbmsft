#if os(iOS)
import UIKit
import SwiftUI
import BMSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        print("📱 [SceneDelegate] ====== SCENE WILL CONNECT ======")
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // Create the root view
        let rootView = RootView()
            .preferredColorScheme(.dark)
            .background(Color.black)
            .ignoresSafeArea()
        
        let hostingController = UIHostingController(rootView: rootView)
        window.rootViewController = hostingController
        self.window = window
        window.makeKeyAndVisible()
        
        print("📱 [SceneDelegate] ====== SCENE CONNECTED ======")
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        print("📱 [SceneDelegate] ====== SCENE DISCONNECTED ======")
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("📱 [SceneDelegate] ====== SCENE BECAME ACTIVE ======")
        // Check auth status when app becomes active
        if let hostingController = window?.rootViewController as? UIHostingController<RootView> {
            let rootView = hostingController.rootView
            rootView.viewModel.refreshAuthStatus()
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print("📱 [SceneDelegate] ====== SCENE WILL RESIGN ACTIVE ======")
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("📱 [SceneDelegate] ====== SCENE WILL ENTER FOREGROUND ======")
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("📱 [SceneDelegate] ====== SCENE DID ENTER BACKGROUND ======")
    }
}
#endif
