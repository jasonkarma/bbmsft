import Foundation

public class EncyclopediaAPIService: APIService {
    public static let shared = EncyclopediaAPIService()
    
    private override init() {
        super.init()
    }
    
    public func getFrontPageContent(token: String) async throws -> FrontPageContent {
        return try await makeRequest(
            "/beauty/frontPageContent",
            method: "GET",
            token: token
        )
    }
    
    public func getArticleDetail(id: Int, token: String) async throws -> ArticleDetail {
        return try await makeRequest(
            "/pageContentArticle/\(id)",
            method: "GET",
            token: token
        )
    }
}
