import Foundation

extension BMNetworkV2.Encyclopedia {
    /// Feature namespace for encyclopedia
    public static var featureNamespace: String { "encyclopedia" }
    
    /// Register encyclopedia types with type system
    public static func register() {
        // Register with type registry
        try? TypeRegistry.shared.register(ArticlePreview.self, in: featureNamespace)
        try? TypeRegistry.shared.register(FrontPageResponse.self, in: featureNamespace)
        try? TypeRegistry.shared.register(ArticleResponse.self, in: featureNamespace)
        try? TypeRegistry.shared.register(LikeRequest.self, in: featureNamespace)
        try? TypeRegistry.shared.register(LikeActionResponse.self, in: featureNamespace)
        try? TypeRegistry.shared.register(Comment.self, in: featureNamespace)
        try? TypeRegistry.shared.register(CommentResponse.self, in: featureNamespace)
        try? TypeRegistry.shared.register(CommentRequest.self, in: featureNamespace)
        
        // Register with type mapping system
        TypeMapping.registerModel(ArticlePreview.self)
        TypeMapping.registerModel(FrontPageResponse.self)
        TypeMapping.registerModel(ArticleResponse.self)
        TypeMapping.registerModel(LikeRequest.self)
        TypeMapping.registerModel(LikeActionResponse.self)
        TypeMapping.registerModel(Comment.self)
        TypeMapping.registerModel(CommentResponse.self)
        TypeMapping.registerModel(CommentRequest.self)
        
        // Register valid conversions
        TypeMapping.registerConversion(from: ArticlePreview.self, to: ArticleResponse.self)
    }
    public protocol EncyclopediaServiceProtocol {
        func getFrontPage() async throws -> FrontPageResponse
        func getArticle(id: Int) async throws -> ArticleResponse
        func likeArticle(id: Int) async throws -> LikeActionResponse
        func visitArticle(id: Int) async throws
        func getComments(articleId: Int) async throws -> CommentResponse
        func postComment(content: String, articleId: Int) async throws -> ClientActionResponse
    }
    
    public final class Service: EncyclopediaServiceProtocol {
        private let client: NetworkClient
        private let tokenManager: TokenManagerProtocol
        
        public init(client: NetworkClient = .shared, tokenManager: TokenManagerProtocol) throws {
            // Validate feature registration
            try RuntimeChecks.validateFeatureRegistration(featureNamespace)
            self.client = client
            self.tokenManager = tokenManager
        }
        
        public func getFrontPage() async throws -> FrontPageResponse {
            // Validate feature access and get token
            try RuntimeChecks.validateFeatureAccess(featureNamespace)
            let token = try tokenManager.getToken()
            let endpoint = EncyclopediaEndpoints.FrontPage()
            return try await client.send(endpoint, body: EmptyRequest(), token: token)
        }
        
        public func getArticle(id: Int) async throws -> ArticleResponse {
            // Validate feature access and get token
            try RuntimeChecks.validateFeatureAccess(featureNamespace)
            let token = try tokenManager.getToken()
            let endpoint = EncyclopediaEndpoints.Article(id: id)
            return try await client.send(endpoint, body: EmptyRequest(), token: token)
        }
        
        public func likeArticle(id: Int) async throws -> LikeActionResponse {
            // Validate feature access and get token
            try RuntimeChecks.validateFeatureAccess(featureNamespace)
            let token = try tokenManager.getToken()
            let endpoint = EncyclopediaEndpoints.LikeArticle()
            let request = LikeRequest(bpSubsectionId: id)
            return try await client.send(endpoint, body: request, token: token)
        }
        
        public func visitArticle(id: Int) async throws {
            // Validate feature access and get token
            try RuntimeChecks.validateFeatureAccess(featureNamespace)
            let token = try tokenManager.getToken()
            let endpoint = EncyclopediaEndpoints.VisitArticle(id: id)
            _ = try await client.send(endpoint, body: EmptyRequest(), token: token)
        }
        
        public func getComments(articleId: Int) async throws -> CommentResponse {
            // Validate feature access and get token
            try RuntimeChecks.validateFeatureAccess(featureNamespace)
            let token = try tokenManager.getToken()
            let endpoint = EncyclopediaEndpoints.Comments(id: articleId)
            return try await client.send(endpoint, body: EmptyRequest(), token: token)
        }
        
        public func postComment(content: String, articleId: Int) async throws -> ClientActionResponse {
            // Validate feature access and get token
            try RuntimeChecks.validateFeatureAccess(featureNamespace)
            let token = try tokenManager.getToken()
            let endpoint = EncyclopediaEndpoints.PostComment()
            let request = CommentRequest(content: content, articleId: articleId)
            return try await client.send(endpoint, body: request, token: token)
        }
    }
}
