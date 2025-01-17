import Foundation

/// Endpoints for the Encyclopedia feature
public enum EncyclopediaEndpoints {
    
    /// Empty request type for endpoints that don't need request body
    public struct EmptyRequest: Codable {
        public init() {}
    }
    
    // MARK: - Endpoint Definitions
    /// Front page endpoint
    public struct FrontPage: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = FrontPageResponse
        
        public let path: String = "/api/beauty/frontPageContent"
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        
        public init(authToken: String) {
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
    }
    
    /// Article endpoint
    public struct Article: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = ArticleResponse
        
        public let id: Int
        public let path: String
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        
        public init(id: Int, authToken: String) {
            self.id = id
            self.path = "/api/pageContentArticle/\(id)"
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
    }
    
    /// Like article endpoint
    public struct Like: BMNetwork.APIEndpoint {
        public typealias RequestType = [String: Int]
        public typealias ResponseType = LikeActionResponse
        
        public let id: Int
        public let path: String = "/api/clientLike"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        
        public init(id: Int, authToken: String) {
            self.id = id
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
        
        public var body: [String: Int] {
            ["bp_subsection_id": id]
        }
    }
    
    /// Visit article endpoint
    public struct Visit: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = BMNetwork.EmptyResponse
        
        public let id: Int
        public let path: String
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        
        public init(id: Int, authToken: String) {
            self.id = id
            self.path = "/api/beauty/article/\(id)/visit"
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
    }
    
    /// Article detail endpoint
    public struct ArticleDetail: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = ArticleDetailResponse
        
        public let id: Int
        public let path: String
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        
        public init(id: Int, authToken: String) {
            self.id = id
            self.path = "/api/pageContentArticle/\(id)"
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
    }
    
    /// Comments endpoint
    public struct Comments: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = CommentResponse
        
        public let id: Int
        public let path: String
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = false
        public let headers: [String: String]
        
        public init(id: Int, authToken: String) {
            self.id = id
            self.path = "/api/content/comment/\(id)"
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
    }
    
    /// Post comment endpoint
    public struct PostComment: BMNetwork.APIEndpoint {
        public typealias RequestType = CommentRequest
        public typealias ResponseType = ClientActionResponse
        
        public let articleId: Int
        public let content: String
        public let path: String = "/api/comment/store"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        
        public init(articleId: Int, content: String, authToken: String) {
            self.articleId = articleId
            self.content = content
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
    }
    
    /// Keep article endpoint
    public struct Keep: BMNetwork.APIEndpoint {
        public typealias RequestType = ClientActionRequest
        public typealias ResponseType = ClientActionResponse
        
        public let id: Int
        public let path: String = "/api/clientKeep"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        
        public init(id: Int, authToken: String) {
            self.id = id
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
    }
}

// MARK: - Factory Methods
public extension EncyclopediaEndpoints {
    static func frontPage(authToken: String) -> BMNetwork.APIRequest<FrontPage> {
        let endpoint = FrontPage(authToken: authToken)
        return BMNetwork.APIRequest(endpoint: endpoint, body: nil)
    }
    
    static func article(id: Int, authToken: String) -> BMNetwork.APIRequest<Article> {
        let endpoint = Article(id: id, authToken: authToken)
        return BMNetwork.APIRequest(endpoint: endpoint, body: nil)
    }
    
    static func like(id: Int, authToken: String) -> BMNetwork.APIRequest<Like> {
        let endpoint = Like(id: id, authToken: authToken)
        let body = endpoint.body
        return BMNetwork.APIRequest(endpoint: endpoint, body: body)
    }
    
    static func visit(id: Int, authToken: String) -> BMNetwork.APIRequest<Visit> {
        let endpoint = Visit(id: id, authToken: authToken)
        return BMNetwork.APIRequest(endpoint: endpoint, body: nil)
    }
    
    static func articleDetail(id: Int, authToken: String) -> BMNetwork.APIRequest<ArticleDetail> {
        let endpoint = ArticleDetail(id: id, authToken: authToken)
        return BMNetwork.APIRequest(endpoint: endpoint, body: nil)
    }
    
    static func comments(id: Int, authToken: String) -> BMNetwork.APIRequest<Comments> {
        let endpoint = Comments(id: id, authToken: authToken)
        return BMNetwork.APIRequest(endpoint: endpoint, body: nil)
    }
    
    static func postComment(articleId: Int, content: String, authToken: String) -> BMNetwork.APIRequest<PostComment> {
        let endpoint = PostComment(articleId: articleId, content: content, authToken: authToken)
        let body = CommentRequest(bp_subsection_id: articleId, cnt: content)
        return BMNetwork.APIRequest(endpoint: endpoint, body: body)
    }
    
    static func keep(id: Int, authToken: String) -> BMNetwork.APIRequest<Keep> {
        let endpoint = Keep(id: id, authToken: authToken)
        let body = ClientActionRequest(bp_subsection_id: id)
        return BMNetwork.APIRequest(endpoint: endpoint, body: body)
    }
}

// MARK: - Convenience Extensions
public extension EncyclopediaEndpoints.Article {
    var likeEndpoint: EncyclopediaEndpoints.Like {
        EncyclopediaEndpoints.Like(id: id, authToken: "")
    }
    
    var visitEndpoint: EncyclopediaEndpoints.Visit {
        EncyclopediaEndpoints.Visit(id: id, authToken: "")
    }
}
