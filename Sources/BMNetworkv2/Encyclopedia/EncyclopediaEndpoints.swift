import Foundation

extension BMNetworkV2 {
    public enum EncyclopediaEndpoints {
        // MARK: - Front Page
        public struct FrontPage: APIEndpoint {
            public typealias RequestType = EmptyRequest
            public typealias ResponseType = FrontPageResponse
            
            public var path: String { "/api/beauty/frontPageContent" }
            public var method: HTTPMethod { .get }
            
            public init() {}
        }
        
        // MARK: - Article
        public struct Article: APIEndpoint {
            public typealias RequestType = EmptyRequest
            public typealias ResponseType = ArticleResponse
            
            public let id: Int
            public var path: String { "/api/pageContentArticle/\(id)" }
            public var method: HTTPMethod { .get }
            
            public init(id: Int) {
                self.id = id
            }
        }
        
        // MARK: - Like Article
        public struct LikeArticle: APIEndpoint {
            public typealias RequestType = LikeRequest
            public typealias ResponseType = LikeActionResponse
            
            public var path: String { "/api/clientLike" }
            public var method: HTTPMethod { .post }
            
            public init() {}
        }
        
        // MARK: - Visit Article
        public struct VisitArticle: APIEndpoint {
            public typealias RequestType = EmptyRequest
            public typealias ResponseType = EmptyResponse
            
            public let id: Int
            public var path: String { "/api/beauty/article/\(id)/visit" }
            public var method: HTTPMethod { .post }
            
            public init(id: Int) {
                self.id = id
            }
        }
        
        // MARK: - Comments
        public struct Comments: APIEndpoint {
            public typealias RequestType = EmptyRequest
            public typealias ResponseType = CommentResponse
            
            public let id: Int
            public var path: String { "/api/content/comment/\(id)" }
            public var method: HTTPMethod { .get }
            
            public init(id: Int) {
                self.id = id
            }
        }
        
        // MARK: - Post Comment
        public struct PostComment: APIEndpoint {
            public typealias RequestType = CommentRequest
            public typealias ResponseType = ClientActionResponse
            
            public var path: String { "/api/comment/store" }
            public var method: HTTPMethod { .post }
            
            public init() {}
        }
    }
}
