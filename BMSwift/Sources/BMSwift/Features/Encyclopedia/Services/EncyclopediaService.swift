import Foundation

public protocol EncyclopediaServiceProtocol {
    func getFrontPageContent(authToken: String) async throws -> FrontPageResponse
    func getArticle(id: Int, authToken: String) async throws -> EncyclopediaAPI.ArticleResponse
    func likeArticle(id: Int) async throws
    func visitArticle(id: Int) async throws
}

public final class EncyclopediaService: EncyclopediaServiceProtocol {
    // MARK: - Properties
    private let client: NetworkClient
    
    // MARK: - Initialization
    public init(client: NetworkClient) {
        self.client = client
    }
    
    // MARK: - Encyclopedia Methods
    public func getFrontPageContent(authToken: String) async throws -> FrontPageResponse {
        let request = EncyclopediaEndpoints.frontPage(authToken: authToken)
        return try await client.send(request)
    }
    
    public func getArticle(id: Int, authToken: String) async throws -> EncyclopediaAPI.ArticleResponse {
        let request = EncyclopediaEndpoints.article(id: id, authToken: authToken)
        return try await client.send(request)
    }
    
    public func likeArticle(id: Int) async throws {
        _ = try await apiClient.request(EncyclopediaAPI.likeArticle(id: id).interactionEndpoint)
    }
    
    public func visitArticle(id: Int) async throws {
        _ = try await apiClient.request(EncyclopediaAPI.visitArticle(id: id).interactionEndpoint)
    }
}
