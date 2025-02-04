import Foundation

extension BMNetworkV2 {
    /// Type mapping system to ensure type compatibility
    public enum TypeMapping {
        /// Error thrown when type mapping fails
        public enum Error: LocalizedError {
            case incompatibleTypes(from: Any.Type, to: Any.Type)
            case typeNotFound(name: String)
            case conversionFailed(value: Any, targetType: Any.Type)
            
            public var errorDescription: String? {
                switch self {
                case .incompatibleTypes(let from, let to):
                    return "Cannot convert from '\(from)' to '\(to)'"
                case .typeNotFound(let name):
                    return "Type '\(name)' not found. Make sure it's registered and imported."
                case .conversionFailed(let value, let targetType):
                    return "Failed to convert value '\(value)' to type '\(targetType)'"
                }
            }
        }
        
        /// Type conversion map
        private static var typeMap: [String: Any.Type] = [:]
        
        /// Type conversion rules
        private static var conversionRules: [(Any.Type, Any.Type)] = []
        
        /// Register a type for lookup
        /// - Parameters:
        ///   - type: The type to register
        ///   - name: Optional name override, defaults to type name
        public static func registerType(_ type: Any.Type, name: String? = nil) {
            let typeName = name ?? String(describing: type)
            typeMap[typeName] = type
        }
        
        /// Register a valid type conversion
        /// - Parameters:
        ///   - from: Source type
        ///   - to: Target type
        public static func registerConversion(from: Any.Type, to: Any.Type) {
            conversionRules.append((from, to))
        }
        
        /// Look up a type by name
        /// - Parameter name: The type name to look up
        /// - Returns: The type if found
        /// - Throws: Error if type not found
        public static func lookupType(_ name: String) throws -> Any.Type {
            guard let type = typeMap[name] else {
                throw Error.typeNotFound(name: name)
            }
            return type
        }
        
        /// Check if conversion is possible
        /// - Parameters:
        ///   - from: Source type
        ///   - to: Target type
        /// - Returns: Whether conversion is allowed
        public static func canConvert(from: Any.Type, to: Any.Type) -> Bool {
            // Direct type match
            if from == to { return true }
            
            // Check registered conversions
            return conversionRules.contains { rule in
                rule.0 == from && rule.1 == to
            }
        }
        
        /// Convert a value to target type
        /// - Parameters:
        ///   - value: Value to convert
        ///   - targetType: Type to convert to
        /// - Returns: Converted value
        /// - Throws: Error if conversion fails
        public static func convert<T>(_ value: Any, to targetType: T.Type) throws -> T {
            // Direct cast if possible
            if let result = value as? T {
                return result
            }
            
            // Check if conversion is allowed
            guard canConvert(from: type(of: value), to: T.self) else {
                throw Error.incompatibleTypes(from: type(of: value), to: T.self)
            }
            
            // Handle specific conversions
            switch (value, T.self) {
            case (let str as String, Int.self):
                guard let result = Int(str) as? T else {
                    throw Error.conversionFailed(value: value, targetType: T.self)
                }
                return result
                
            case (let num as Int, String.self):
                guard let result = String(num) as? T else {
                    throw Error.conversionFailed(value: value, targetType: T.self)
                }
                return result
                
            // Add more conversion cases as needed
                
            default:
                throw Error.conversionFailed(value: value, targetType: T.self)
            }
        }
    }
}
