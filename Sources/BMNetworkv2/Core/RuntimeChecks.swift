import Foundation

extension BMNetworkV2 {
    /// Runtime safety checks for network operations
    enum RuntimeChecks {
        /// Error thrown when runtime checks fail
        enum Error: LocalizedError {
            case crossFeatureAccess(attempted: String, allowed: String)
            case missingFeatureNamespace(type: String)
            case invalidAuthState(required: Bool, endpoint: String)
            
            var errorDescription: String? {
                switch self {
                case .crossFeatureAccess(let attempted, let allowed):
                    return "Cross-feature access detected: Attempted to access '\(attempted)' from '\(allowed)' namespace"
                case .missingFeatureNamespace(let type):
                    return "Missing feature namespace for type: \(type)"
                case .invalidAuthState(let required, let endpoint):
                    return "Invalid auth state: endpoint '\(endpoint)' \(required ? "requires" : "does not support") authentication"
                }
            }
        }
        
        /// Validate that the caller has access to the endpoint
        /// - Parameters:
        ///   - endpoint: The endpoint being accessed
        ///   - callerNamespace: The namespace of the caller
        static func validateAccess<E: APIEndpoint>(
            to endpoint: E,
            from callerNamespace: String
        ) throws {
            guard E.featureNamespace == callerNamespace else {
                throw Error.crossFeatureAccess(
                    attempted: E.featureNamespace,
                    allowed: callerNamespace
                )
            }
        }
        
        /// Validate authentication state for an endpoint
        /// - Parameters:
        ///   - endpoint: The endpoint to validate
        ///   - hasToken: Whether we have an auth token
        static func validateAuth<E: APIEndpoint>(
            for endpoint: E,
            hasToken: Bool
        ) throws {
            if endpoint.requiresAuth && !hasToken {
                throw Error.invalidAuthState(
                    required: true,
                    endpoint: String(describing: E.self)
                )
            }
            if !endpoint.requiresAuth && hasToken {
                throw Error.invalidAuthState(
                    required: false,
                    endpoint: String(describing: E.self)
                )
            }
        }
    }
}
