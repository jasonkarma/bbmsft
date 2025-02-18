import Foundation

/// Protocol defining the keywords service interface
public protocol KeywordsServiceProtocol {
    /// Get hot keywords
    /// - Parameter authToken: Authentication token
    /// - Returns: HotKeywordsResponse containing hot keywords
    func getHotKeywords(authToken: String) async throws -> BMSearchV2.Keywords.HotKeywordsResponse
    
    /// Get all keywords
    /// - Parameter authToken: Authentication token
    /// - Returns: AllKeywordsResponse containing all keywords
    func getAllKeywords(authToken: String) async throws -> BMSearchV2.Keywords.AllKeywordsResponse
}

/// Implementation of keywords service
final class KeywordsService: KeywordsServiceProtocol {
    private let client: BMNetwork.NetworkClient
    
    init(client: BMNetwork.NetworkClient) {
        self.client = client
    }
    
    func getHotKeywords(authToken: String) async throws -> BMSearchV2.Keywords.HotKeywordsResponse {
        print("[Keywords] Getting hot keywords...")
        let request = BMNetwork.APIRequest(
            endpoint: BMSearchV2.Keywords.HotKeywordsEndpoint(authToken: authToken),
            body: nil,
            authToken: authToken
        )
        return try await client.send(request)
    }
    
    func getAllKeywords(authToken: String) async throws -> BMSearchV2.Keywords.AllKeywordsResponse {
        print("[Keywords] Getting all keywords...")
        let request = BMNetwork.APIRequest(
            endpoint: BMSearchV2.Keywords.AllKeywordsEndpoint(authToken: authToken),
            body: nil,
            authToken: authToken
        )
        return try await client.send(request)
    }
}
