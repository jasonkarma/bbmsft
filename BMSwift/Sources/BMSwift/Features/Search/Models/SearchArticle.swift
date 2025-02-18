import Foundation

public extension BMSearchV2.Search {
    struct SearchArticle: Codable, Identifiable, ArticleCardModel {
        public let id: Int
        public let title: String
        public let intro: String
        public let mediaName: String
        
        public init(id: Int, title: String, intro: String, mediaName: String) {
            self.id = id
            self.title = title
            self.intro = intro
            self.mediaName = mediaName
        }
    }
}
