import Foundation

/// Registry for type-safe model registration
public final class TypeRegistry {
    /// Shared instance
    public static let shared = TypeRegistry()
    
    /// Registered types by namespace
    private var types: [String: Set<String>] = [:]
    
    private init() {}
    
    /// Register a type in a namespace
    /// - Parameters:
    ///   - type: Type to register
    ///   - namespace: Namespace to register in
    public func register<T>(_ type: T.Type, in namespace: String) throws {
        let typeName = String(describing: type)
        if types[namespace] == nil {
            types[namespace] = []
        }
        types[namespace]?.insert(typeName)
    }
    
    /// Check if type is registered
    /// - Parameters:
    ///   - type: Type to check
    ///   - namespace: Namespace to check in
    /// - Returns: True if type is registered
    public func isRegistered<T>(_ type: T.Type, in namespace: String) -> Bool {
        let typeName = String(describing: type)
        return types[namespace]?.contains(typeName) ?? false
    }
    
    /// Get all types in namespace
    /// - Parameter namespace: Namespace to get types from
    /// - Returns: Set of type names
    public func types(in namespace: String) -> Set<String> {
        types[namespace] ?? []
    }
    
    /// Clear registry
    public func clear() {
        types.removeAll()
    }
}
