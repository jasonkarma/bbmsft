//
// BMSwiftApp.swift
// BMSwiftApp
//
// Created on 2025-01-14
//

import Foundation

#if os(iOS)
import SwiftUI
import BMSwift

/// BMSwiftApp is the main application entry point.
/// This is the actual app implementation that uses the BMSwift library.
///
/// Features:
/// - Configures the app's global appearance
/// - Sets up the app delegate
/// - Establishes the main navigation flow
/// - Handles app lifecycle
///
/// Architecture:
/// - Uses SwiftUI's App protocol
/// - Implements UIApplicationDelegate for iOS-specific functionality
/// - Integrates BMSwift library components
@main
struct BMSwiftApp: App {
    // MARK: - Properties
    
    /// App delegate adaptor for handling iOS-specific functionality
    /// This includes:
    /// - Push notifications setup
    /// - Deep linking
    /// - Third-party SDK initialization
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - Scene Configuration
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LoginView()
                    .preferredColorScheme(.dark) // Forces dark mode for consistent appearance
                    .background(Color.black)     // Sets default background color
                    .ignoresSafeArea()           // Extends background to edges
            }
        }
    }
    
    // MARK: - Initialization
    
    /// Creates a new instance of BMSwiftApp
    /// This is called automatically by the system since this is marked with @main
    init() {
        // Configure any app-wide settings here
        configureAppearance()
    }
    
    // MARK: - Private Methods
    
    /// Configures the global appearance settings for the app
    private func configureAppearance() {
        // Add any appearance configuration here
    }
}

// MARK: - Preview

#if DEBUG
struct BMSwiftApp_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
#endif
#endif