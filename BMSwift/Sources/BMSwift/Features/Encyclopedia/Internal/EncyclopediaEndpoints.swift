import Foundation

// MARK: - Encyclopedia Endpoints
enum EncyclopediaEndpoints {
    // MARK: - Front Page
    struct FrontPage: APIEndpoint {
        typealias RequestType = Never
        typealias ResponseType = FrontPageResponse
        
        let path = "/api/beauty/frontPageContent"
        let method: HTTPMethod = .get
        let requiresAuth = true
    }
    
    // MARK: - Article
    struct Article: APIEndpoint {
        typealias RequestType = Never
        typealias ResponseType = ArticleResponse
        
        let id: Int
        let path: String
        let method: HTTPMethod = .get
        let requiresAuth = true
        
        init(id: Int) {
            self.id = id
            self.path = "/api/pageContentArticle/\(id)"
        }
    }
}

// MARK: - Factory Methods
extension EncyclopediaEndpoints {
    static func frontPage(authToken: String) -> APIRequest<FrontPage> {
        APIRequest(endpoint: FrontPage(), authToken: authToken)
    }
    
    static func article(id: Int, authToken: String) -> APIRequest<Article> {
        APIRequest(endpoint: Article(id: id), authToken: authToken)
    }
}
