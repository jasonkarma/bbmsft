import Foundation

/// Manages the network environment configuration
public final class NetworkEnvironment {
    /// Shared instance for global access
    public static let shared = NetworkEnvironment()
    
    /// Current active configuration
    private var _configuration: Configuration
    
    /// Access the current configuration
    public var configuration: Configuration {
        get { _configuration }
        set { updateConfiguration(newValue) }
    }
    
    /// Initialize with default production configuration
    private init() {
        self._configuration = .production
    }
    
    /// Update the current configuration
    /// - Parameter configuration: New configuration to use
    private func updateConfiguration(_ configuration: Configuration) {
        self._configuration = configuration
    }
    
    /// Set the environment to production
    public func useProduction() {
        configuration = .production
    }
    
    /// Set the environment to development
    public func useDevelopment() {
        configuration = .development
    }
    
    /// Configure with a custom configuration
    /// - Parameter configuration: Custom configuration to use
    public func configure(with configuration: Configuration) {
        self.configuration = configuration
    }
}
