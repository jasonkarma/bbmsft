import Foundation

/// Factory for creating network layer components
public enum NetworkFactory {
    /// Creates the appropriate network client based on feature flags
    public static func createNetworkClient() -> Any {
        if BMFeatureFlags.useNewNetworkLayer {
            // Use new V2 implementation
            return BMNetworkV2.NetworkClient.shared
        } else {
            // Use existing implementation
            return BMNetwork.NetworkClient.shared
        }
    }
    
    /// Creates the appropriate auth service based on feature flags
    public static func createAuthService() -> Any {
        if BMFeatureFlags.useNewNetworkLayer {
            // Use new V2 implementation
            let client = BMNetworkV2.NetworkClient.shared
            let tokenManager = BMNetworkV2.TokenManager.shared
            return BMNetworkV2.AuthService(client: client, tokenManager: tokenManager)
        } else {
            // Use existing implementation
            // Note: You'll need to add the corresponding types in the old implementation
            fatalError("Old implementation not yet supported")
        }
    }
    
    /// Creates the appropriate encyclopedia service based on feature flags
    public static func createEncyclopediaService() -> Any {
        if BMFeatureFlags.useNewNetworkLayer {
            // Use new V2 implementation
            let client = BMNetworkV2.NetworkClient.shared
            let tokenManager = BMNetworkV2.TokenManager.shared
            return BMNetworkV2.EncyclopediaService(client: client, tokenManager: tokenManager)
        } else {
            // Use existing implementation
            // Note: You'll need to add the corresponding types in the old implementation
            fatalError("Old implementation not yet supported")
        }
    }
}
