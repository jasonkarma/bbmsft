import Foundation

extension BMNetworkV2 {
    // MARK: - Front Page Models
    public struct ArticlePreview: TypeSafeModel, Identifiable {
        public let id: Int
        public let title: String
        public let imageUrl: String?
        public let likes: Int
        public let views: Int
        public let createdAt: Date
        
        public init(id: Int, title: String, imageUrl: String?, likes: Int, views: Int, createdAt: Date) {
            self.id = id
            self.title = title
            self.imageUrl = imageUrl
            self.likes = likes
            self.views = views
            self.createdAt = createdAt
        }
    }
    
    public struct FrontPageResponse: TypeSafeModel {
        public let hotContents: [ArticlePreview]
        public let latestContents: [ArticlePreview]
        
        public init(hotContents: [ArticlePreview], latestContents: [ArticlePreview]) {
            self.hotContents = hotContents
            self.latestContents = latestContents
        }
    }
    
    // MARK: - Article Models
    public struct ArticleResponse: TypeSafeModel {
        public let id: Int
        public let title: String
        public let content: String
        public let imageUrl: String?
        public let likes: Int
        public let views: Int
        
        public init(id: Int, title: String, content: String, imageUrl: String?, likes: Int, views: Int) {
            self.id = id
            self.title = title
            self.content = content
            self.imageUrl = imageUrl
            self.likes = likes
            self.views = views
        }
    }
    
    // MARK: - Like Models
    public struct LikeRequest: TypeSafeModel {
        public let bpSubsectionId: Int
        
        public init(bpSubsectionId: Int) {
            self.bpSubsectionId = bpSubsectionId
        }
    }
    
    public struct LikeActionResponse: TypeSafeModel {
        public let success: Bool
        public let message: String
        
        public init(success: Bool, message: String) {
            self.success = success
            self.message = message
        }
    }
    
    // MARK: - Comment Models
    public struct Comment: TypeSafeModel, Identifiable {
        public let id: Int
        public let content: String
        public let userId: Int
        public let username: String
        public let createdAt: Date
        
        public init(id: Int, content: String, userId: Int, username: String, createdAt: Date) {
            self.id = id
            self.content = content
            self.userId = userId
            self.username = username
            self.createdAt = createdAt
        }
    }
    
    public struct CommentResponse: TypeSafeModel {
        public let comments: [Comment]
        public let total: Int
        
        public init(comments: [Comment], total: Int) {
            self.comments = comments
            self.total = total
        }
    }
    
    public struct CommentRequest: TypeSafeModel {
        public let content: String
        public let articleId: Int
        
        public init(content: String, articleId: Int) {
            self.content = content
            self.articleId = articleId
        }
    }
    
    public struct ClientActionResponse: Codable {
        public let success: Bool
        public let message: String
        
        public init(success: Bool, message: String) {
            self.success = success
            self.message = message
        }
    }
}
