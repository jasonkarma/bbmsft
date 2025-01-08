#if canImport(SwiftUI) && os(iOS)
import Foundation

/// Environment configuration for the application
public enum Environment {
    /// Development environment for testing
    case development
    /// Staging environment for pre-production testing
    case staging
    /// Production environment
    case production
    
    /// Current environment
    public static var current: Environment = {
        #if DEBUG
        return .development
        #else
        // You can use different build configurations to set this
        return .production
        #endif
    }()
    
    /// Base URL for API requests
    public var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://dev-api.bmswift.com")!
        case .staging:
            return URL(string: "https://staging-api.bmswift.com")!
        case .production:
            return URL(string: "https://api.bmswift.com")!
        }
    }
    
    /// API Key for the environment
    public var apiKey: String {
        switch self {
        case .development:
            return "dev_api_key"
        case .staging:
            return "staging_api_key"
        case .production:
            // In production, this should be fetched from a secure source
            return "prod_api_key"
        }
    }
    
    /// Timeout interval for network requests
    public var networkTimeoutInterval: TimeInterval {
        switch self {
        case .development:
            return 60
        case .staging:
            return 30
        case .production:
            return 30
        }
    }
    
    /// Maximum retry attempts for network requests
    public var maxRetryAttempts: Int {
        switch self {
        case .development:
            return 3
        case .staging:
            return 2
        case .production:
            return 1
        }
    }
    
    /// Flag to enable detailed logging
    public var enableDetailedLogs: Bool {
        switch self {
        case .development, .staging:
            return true
        case .production:
            return false
        }
    }
}

/// Configuration for different build types
public enum BuildConfiguration {
    /// Debug build configuration
    case debug
    /// Release build configuration
    case release
    
    /// Current build configuration
    public static var current: BuildConfiguration {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }
}
#endif
