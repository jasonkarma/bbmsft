//
// BMSwiftApp.swift
// BMSwift
//
// Created on 2025-01-14
//

#if canImport(SwiftUI) && os(iOS)
import SwiftUI

/// BMSwiftMainView serves as the main preview and example view for the BMSwift library.
/// This view is intentionally not marked with @main as it's part of the library module,
/// not the main application.
///
/// Purpose:
/// - Demonstrates how to use BMSwift components
/// - Provides a preview environment for library development
/// - Serves as an example implementation for library users
///
/// Usage:
/// ```swift
/// import BMSwift
///
/// struct YourView: View {
///     var body: some View {
///         BMSwiftMainView()
///     }
/// }
/// ```
public struct BMSwiftMainView: View {
    // MARK: - View Body
    
    public var body: some View {
        LoginView()
    }
    
    // MARK: - Initialization
    
    /// Creates a new instance of BMSwiftMainView
    public init() {}
}

// MARK: - Previews

/// Preview provider for BMSwiftMainView
/// Shows how the view looks in different contexts and configurations
struct BMSwiftMainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default preview
            BMSwiftMainView()
            
            // Dark mode preview
            BMSwiftMainView()
                .preferredColorScheme(.dark)
        }
    }
}
#endif