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
            self.path = "/api/article/\(id)"
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
    }
    
    /// Like article endpoint
    public struct Like: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = BMNetwork.EmptyResponse
        
        public let id: Int
        public let path: String
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        
        public init(id: Int, authToken: String) {
            self.id = id
            self.path = "/api/article/\(id)/like"
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
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
            self.path = "/api/article/\(id)/visit"
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
        return BMNetwork.APIRequest(endpoint: endpoint, body: nil)
    }
    
    static func visit(id: Int, authToken: String) -> BMNetwork.APIRequest<Visit> {
        let endpoint = Visit(id: id, authToken: authToken)
        return BMNetwork.APIRequest(endpoint: endpoint, body: nil)
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
