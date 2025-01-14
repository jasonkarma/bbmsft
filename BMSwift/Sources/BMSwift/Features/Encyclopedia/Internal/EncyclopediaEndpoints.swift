import Foundation

/// Namespace for Encyclopedia-related API endpoints
public enum EncyclopediaEndpoints {
    /// Front page endpoint
    public struct FrontPage: APIEndpoint {
        public typealias RequestType = Never
        public typealias ResponseType = FrontPageResponse
        
        public let path = "/api/beauty/frontPageContent"
        public let method: HTTPMethod = .get
        public let requiresAuth = true
        
        public init() {}
    }
    
    /// Article endpoint
    public struct Article: APIEndpoint {
        public typealias RequestType = Never
        public typealias ResponseType = ArticleResponse
        
        public let id: Int
        public let path: String
        public let method: HTTPMethod = .get
        public let requiresAuth = true
        
        public init(id: Int) {
            self.id = id
            self.path = "/api/pageContentArticle/\(id)"
        }
        
        /// Creates an endpoint for liking an article
        public var likeEndpoint: Like {
            Like(id: id)
        }
        
        /// Creates an endpoint for recording a visit
        public var visitEndpoint: Visit {
            Visit(id: id)
        }
    }
    
    /// Like article endpoint
    public struct Like: APIEndpoint {
        public typealias RequestType = Never
        public typealias ResponseType = EmptyResponse
        
        public let id: Int
        public let path: String
        public let method: HTTPMethod = .post
        public let requiresAuth = true
        
        public init(id: Int) {
            self.id = id
            self.path = "/api/article/\(id)/like"
        }
    }
    
    /// Visit article endpoint
    public struct Visit: APIEndpoint {
        public typealias RequestType = Never
        public typealias ResponseType = EmptyResponse
        
        public let id: Int
        public let path: String
        public let method: HTTPMethod = .post
        public let requiresAuth = true
        
        public init(id: Int) {
            self.id = id
            self.path = "/api/article/\(id)/visit"
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
