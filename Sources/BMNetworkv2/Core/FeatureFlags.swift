import Foundation

/// Feature flags for controlling network layer behavior
public enum BMFeatureFlags {
    /// Controls which network implementation to use
    public static var useNewNetworkLayer: Bool {
        get {
            UserDefaults.standard.bool(forKey: "BMNetwork.useNewNetworkLayer")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BMNetwork.useNewNetworkLayer")
        }
    }
    
    /// Enables verbose network logging
    public static var enableNetworkLogs: Bool {
        get {
            UserDefaults.standard.bool(forKey: "BMNetwork.enableNetworkLogs")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BMNetwork.enableNetworkLogs")
        }
    }
    
    /// Helper method to enable all new features
    public static func enableAllNewFeatures() {
        useNewNetworkLayer = true
        enableNetworkLogs = true
    }
    
    /// Helper method to disable all new features
    public static func disableAllNewFeatures() {
        useNewNetworkLayer = false
        enableNetworkLogs = false
    }
    
    /// Reset all feature flags to default values
    public static func resetToDefaults() {
        let domain = Bundle.main.bundleIdentifier ?? "com.kinglyrobot.bmswift"
        UserDefaults.standard.removePersistentDomain(forName: domain)
    }
}
