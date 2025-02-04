import Foundation

/// Protocol for type-safe model conversion
public protocol TypeSafeModel: Codable {
    /// Convert to another type safely
    /// - Parameter type: Target type
    /// - Returns: Converted value
    /// - Throws: Error if conversion fails
    func convert<T: TypeSafeModel>(to type: T.Type) throws -> T
    
    /// The type identifier for this model
    static var typeIdentifier: String { get }
}

extension TypeSafeModel {
    public func convert<T: TypeSafeModel>(to type: T.Type) throws -> T {
        // First check if types are compatible
        try BMNetworkV2.TypeMapping.validateConversion(from: Self.self, to: T.self)
        
        // Encode self to data
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        
        // Decode to target type
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    public static var typeIdentifier: String {
        String(describing: self)
    }
}

// MARK: - Type Registration

extension BMNetworkV2.TypeMapping {
    /// Register a model type
    /// - Parameter model: The model type to register
    public static func registerModel<T: TypeSafeModel>(_ model: T.Type) {
        registerType(model, name: model.typeIdentifier)
    }
    
    /// Validate type conversion
    /// - Parameters:
    ///   - from: Source type
    ///   - to: Target type
    /// - Throws: Error if conversion not possible
    public static func validateConversion(from: Any.Type, to: Any.Type) throws {
        guard canConvert(from: from, to: to) else {
            throw Error.incompatibleTypes(from: from, to: to)
        }
    }
}
