import Foundation

/// Core API control layer that coordinates network requests and authentication.
/// This class provides the foundation for feature-specific services by handling:
/// - Generic request sending with automatic token management
/// - Authentication state coordination
/// - Token storage and retrieval
public final class APIControl {
    // MARK: - Properties
    private let client: BMNetworkcl.NetworkClient
    private let authActor: AuthenticationActor
    
    // MARK: - Initialization
    public init(client: BMNetworkcl.NetworkClient = .shared, authActor: AuthenticationActor = .shared) {
        self.client = client
        self.authActor = authActor
    }
    
    // MARK: - Core API Methods
    /// Send a request that requires authentication
    public func send<E: BMNetwork.APIEndpoint>(_ request: BMNetwork.APIRequest<E>) async throws -> E.ResponseType {
        // Handle authentication if needed
        if request.endpoint.requiresAuth {
            let token = await authActor.getToken()
            let authenticatedRequest = BMNetwork.APIRequest(
                endpoint: request.endpoint,
                body: request.body,
                authToken: token,
                queryItems: request.queryItems
            )
            let response = try await client.send(authenticatedRequest)
            return response
        }
        
        let response = try await client.send(request)
        return response
    }
    
    /// Send a request without authentication
    public func sendUnauthenticated<E: BMNetwork.APIEndpoint>(_ request: BMNetwork.APIRequest<E>) async throws -> E.ResponseType {
        try await client.send(request)
    }
}

// MARK: - Shared Instance
public extension APIControl {
    static let shared = APIControl()
}
