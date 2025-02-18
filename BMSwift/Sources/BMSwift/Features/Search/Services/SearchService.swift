import Foundation

/// Protocol defining the search service interface
public protocol SearchServiceProtocol {
    /// Search for articles
    /// - Parameters:
    ///   - type: Type of content to search for
    ///   - bpTagId: Tag ID to search with
    ///   - page: Page number for pagination
    ///   - authToken: Authentication token
    /// - Returns: SearchResponse containing article results
    func searchArticles(type: BMSearchV2.Search.SearchType, bpTagId: String, page: Int, authToken: String) async throws -> BMSearchV2.Search.SearchResponse
}

/// Implementation of search service
final class SearchService: SearchServiceProtocol {
    private let client: BMNetwork.NetworkClient
    
    init(client: BMNetwork.NetworkClient) {
        self.client = client
    }
    
    func searchArticles(type: BMSearchV2.Search.SearchType, bpTagId: String, page: Int, authToken: String) async throws -> BMSearchV2.Search.SearchResponse {
        print("[Search] Searching articles with type: \(type), bpTagId: \(bpTagId), page: \(page)...")
        let request = BMNetwork.APIRequest(
            endpoint: BMSearchV2.Search.SearchEndpoint(type: type, bpTagId: bpTagId, page: page, authToken: authToken),
            body: nil,
            authToken: authToken
        )
        return try await client.send(request)
    }
}

