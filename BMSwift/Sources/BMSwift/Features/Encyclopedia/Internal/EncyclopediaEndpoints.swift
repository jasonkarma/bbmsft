import Foundation

/// Endpoints for the Encyclopedia feature
public enum EncyclopediaEndpoints {
    
    /// Empty request type for endpoints that don't need request body
    public struct EmptyRequest: Codable {}
    
    // MARK: - Endpoint Definitions
    /// Front page endpoint
    public struct FrontPage: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest
        public typealias ResponseType = FrontPageResponse
        
        public let path: String = "/api/encyclopedia/front-page"
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = true
        public let headers: [String: String] = ["Content-Type": "application/json"]
        
        public init() {}
    }
    
    /// Article endpoint
    public struct Article: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest
        public typealias ResponseType = ArticleResponse
        
        public let id: Int
        public let path: String
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = true
        public let headers: [String: String] = ["Content-Type": "application/json"]
        
        public init(id: Int) {
            self.id = id
            self.path = "/api/article/\(id)"
        }
    }
    
    /// Like article endpoint
    public struct Like: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest
        public typealias ResponseType = BMNetwork.EmptyResponse
        
        public let id: Int
        public let path: String
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = true
        public let headers: [String: String] = ["Content-Type": "application/json"]
        
        public init(id: Int) {
            self.id = id
            self.path = "/api/article/\(id)/like"
        }
    }
    
    /// Visit article endpoint
    public struct Visit: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest
        public typealias ResponseType = BMNetwork.EmptyResponse
        
        public let id: Int
        public let path: String
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = true
        public let headers: [String: String] = ["Content-Type": "application/json"]
        
        public init(id: Int) {
            self.id = id
            self.path = "/api/article/\(id)/visit"
        }
    }
}

// MARK: - Factory Methods
public extension EncyclopediaEndpoints {
    static func frontPage(authToken: String) -> BMNetwork.APIRequest<FrontPage> {
        BMNetwork.APIRequest(endpoint: FrontPage(), authToken: authToken)
    }
    
    static func article(id: Int, authToken: String) -> BMNetwork.APIRequest<Article> {
        BMNetwork.APIRequest(endpoint: Article(id: id), authToken: authToken)
    }
    
    static func like(id: Int) -> BMNetwork.APIRequest<Like> {
        BMNetwork.APIRequest(endpoint: Like(id: id))
    }
    
    static func visit(id: Int) -> BMNetwork.APIRequest<Visit> {
        BMNetwork.APIRequest(endpoint: Visit(id: id))
    }
}

// MARK: - Article Extensions
public extension EncyclopediaEndpoints.Article {
    var likeEndpoint: EncyclopediaEndpoints.Like {
        EncyclopediaEndpoints.Like(id: id)
    }
    
    var visitEndpoint: EncyclopediaEndpoints.Visit {
        EncyclopediaEndpoints.Visit(id: id)
    }
}
