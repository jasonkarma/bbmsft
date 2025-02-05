import Foundation

/// Namespace for all BMNetwork types to prevent ambiguity with other modules
public enum BMNetworkV2 {
    /// Core networking types
    public enum Core {}
    
    /// Authentication feature types
    public enum Auth {}
    
    /// Encyclopedia feature types
    public enum Encyclopedia {}
    
    /// Skin Analysis feature types
    public enum SkinAnalysis {}
}

// MARK: - Type Aliases

public extension BMNetworkV2 {
    /// Network client type alias to prevent confusion with old implementation
    typealias Client = NetworkClient
    
    /// Configuration type alias
    typealias Config = Configuration
    
    /// Error type alias
    typealias Error = APIError
}

// MARK: - Feature Type Registration

/// Protocol for registering feature types to prevent duplicates
public protocol FeatureTypeRegistry {
    /// Unique identifier for the feature
    static var featureId: String { get }
    
    /// Register types with the runtime system
    static func register()
}

/// Runtime type checking system
public final class TypeRegistry {
    /// Singleton instance
    public static let shared = TypeRegistry()
    
    /// Registered feature types
    private var registeredFeatures: Set<String> = []
    /// Registered type names within features
    private var registeredTypes: [String: Set<String>] = [:]
    
    private init() {}
    
    /// Register a type with the system
    /// - Parameters:
    ///   - type: The type to register
    ///   - featureId: The feature namespace
    /// - Throws: Error if type is already registered
    public func register(_ type: Any.Type, in featureId: String) throws {
        let typeName = String(describing: type)
        
        // Create feature namespace if needed
        if !registeredFeatures.contains(featureId) {
            registeredFeatures.insert(featureId)
            registeredTypes[featureId] = []
        }
        
        // Check for type conflicts
        guard !registeredTypes[featureId]!.contains(typeName) else {
            throw RuntimeError.typeConflict(
                type: typeName,
                feature: featureId
            )
        }
        
        // Register the type
        registeredTypes[featureId]!.insert(typeName)
    }
}

// MARK: - Runtime Errors

extension BMNetworkV2 {
    /// Runtime errors for type system
    public enum RuntimeError: LocalizedError {
        case typeConflict(type: String, feature: String)
        case namespaceConflict(namespace: String)
        
        public var errorDescription: String? {
            switch self {
            case .typeConflict(let type, let feature):
                return "Type '\(type)' is already registered in feature '\(feature)'"
            case .namespaceConflict(let namespace):
                return "Namespace '\(namespace)' is already registered"
            }
        }
    }
}
