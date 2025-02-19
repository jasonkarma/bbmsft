import Foundation



// MARK: - Keywords Feature
public extension BMSearchV2.Keywords {
    /// Hot keywords response - array of keyword models
    typealias HotKeywordsResponse = [KeywordModel]
    
    /// All keywords response - array of keyword models
    typealias AllKeywordsResponse = [KeywordModel]
}

// MARK: - Search Feature
public extension BMSearchV2.Search {
    /// Search content type
    enum SearchType: Int, CaseIterable {
        case type1 = 1
        case type2 = 2
        case type3 = 3
        case type4 = 4
        
        public var title: String {
            switch self {
            case .type1: return "Type 1"
            case .type2: return "Type 2"
            case .type3: return "Type 3"
            case .type4: return "Type 4"
            }
        }
    }
    
    /// Main search response
    struct SearchResponse: Codable {
        public struct SearchArticle: Codable, Hashable, Identifiable, ArticleCardModel {
            // Common fields for both type 0 and type 1+
            public let bp_subsection_id: Int
            public let bp_subsection_title: String
            public let bp_subsection_intro: String
            public let bp_subsection_first_enabled_at: String
            public let media_name: String
            public let visit: Int
            public let likecount: Int
            public let hashtag: [HashTag]
            
            // Type 0 specific field
            public let content_type: [ContentTypeDetail]?
            
            // Type 1+ specific fields
            public let bp_subsection_type_type: Int?
            public let bp_subsection_type_title: String?
            public let bp_subsection_type_cnt: String?

            public var id: Int { bp_subsection_id }
            public var title: String { bp_subsection_title }
            public var intro: String { bp_subsection_intro }
            public var mediaName: String { media_name }
            public var visitCount: Int { visit }
            public var likeCount: Int { likecount }
            public var platform: Int { bp_subsection_type_type ?? 0 }
            public var clientLike: Bool { false }
            public var clientVisit: Bool { false }
            public var clientKeep: Bool { false }
            
            // MARK: - Hashable
            public func hash(into hasher: inout Hasher) {
                hasher.combine(bp_subsection_id)
            }
            
            // MARK: - Equatable
            public static func == (lhs: SearchArticle, rhs: SearchArticle) -> Bool {
                lhs.bp_subsection_id == rhs.bp_subsection_id
            }
        }
        
        public struct Contents: Codable {
            public let current_page: Int
            public let data: [SearchArticle]
            public let first_page_url: String
            public let from: Int
            public let last_page: Int
            public let last_page_url: String
            public let next_page_url: String?
            public let path: String
            public let per_page: Int
            public let prev_page_url: String?
            public let to: Int
            public let total: Int
            public let links: [PageLink]
        }
        
        public struct PageLink: Codable {
            public let url: String?
            public let label: String
            public let active: Bool
        }
        
        public let normalSuggestion: Bool?
        public let contents: Contents
    }
    
    
    struct ContentTypeDetail: Codable {
        public let bp_subsection_type_type: Int
        public let bp_subsection_type_title: String
        public let bp_subsection_type_cnt: String
        public let bp_subsection_id: Int
        
        public init(
            bp_subsection_type_type: Int,
            bp_subsection_type_title: String,
            bp_subsection_type_cnt: String,
            bp_subsection_id: Int
        ) {
            self.bp_subsection_type_type = bp_subsection_type_type
            self.bp_subsection_type_title = bp_subsection_type_title
            self.bp_subsection_type_cnt = bp_subsection_type_cnt
            self.bp_subsection_id = bp_subsection_id
        }
    }
    
    struct HashTag: Codable {
        public let id: Int
        public let hashtag: String
        public let throughKey: Int
        
        private enum CodingKeys: String, CodingKey {
            case id = "bp_tag_id"
            case hashtag = "bp_hashtag"
            case throughKey = "laravel_through_key"
        }
        
        public init(id: Int, hashtag: String, throughKey: Int) {
            self.id = id
            self.hashtag = hashtag
            self.throughKey = throughKey
        }
    }
    
    enum ContentTypeEnum: Int {
        case question = 1
        case reason = 2
        case method = 3
        case suggestion = 4
        case unknown = 0
        
        public var description: String {
            switch self {
            case .question: return "問題"
            case .reason: return "原因"
            case .method: return "方法"
            case .suggestion: return "建議"
            case .unknown: return "未知"
            }
        }
    }
    
    struct ContentType: Decodable {
        public let type: Int
        public let title: String
        public let content: String
        public let articleId: Int
        
        private enum CodingKeys: String, CodingKey {
            case type = "bp_subsection_type_type"
            case title = "bp_subsection_type_title"
            case content = "bp_subsection_type_cnt"
            case articleId = "bp_subsection_id"
        }
        
        // Helper to get content type enum
        public var contentType: ContentTypeEnum {
            ContentTypeEnum(rawValue: type) ?? .unknown
        }
    }
    
}

