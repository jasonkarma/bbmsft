import Foundation

// MARK: - Keywords Feature
public extension BMSearchV2.Keywords {
    /// Hot keywords response
    struct HotKeywordsResponse: Codable {
        public let keywords: [String]
    }
    
    /// All keywords response
    struct AllKeywordsResponse: Codable {
        public let keywords: [String]
    }
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
        public let normalSuggestion: Bool?
        public let contents: Contents
    }
    
    /// Contents wrapper for pagination data
    struct Contents: Codable {
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
    
    /// Link for pagination
    struct PageLink: Codable {
        public let url: String?
        public let label: String
        public let active: Bool
    }
}



public struct SearchArticle: Decodable, Identifiable {
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
    
    // Identifiable conformance
    public var id: Int { bp_subsection_id }
    
    // Helper to determine the type of search result
    public var isTypeZero: Bool {
        content_type != nil
    }
    
    // Helper to get content regardless of type
    public var content: String? {
        if isTypeZero {
            return content_type?.first?.bp_subsection_type_cnt
        } else {
            return bp_subsection_type_cnt
        }
    }
    
    // Helper to get type title regardless of type
    public var typeTitle: String? {
        if isTypeZero {
            return content_type?.first?.bp_subsection_type_title
        } else {
            return bp_subsection_type_title
        }
    }
}

public struct ContentTypeDetail: Codable {
    public let bp_subsection_type_type: Int
    public let bp_subsection_type_title: String
    public let bp_subsection_type_cnt: String
    public let bp_subsection_id: Int
}

public struct HashTag: Decodable {
    public let id: Int
    public let hashtag: String
    public let throughKey: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "bp_tag_id"
        case hashtag = "bp_hashtag"
        case throughKey = "laravel_through_key"
    }
}

public enum ContentTypeEnum: Int {
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

public struct ContentType: Decodable {
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

// MARK: - Helpers
extension SearchArticle {
    func toArticlePreview() -> ArticlePreview {
        ArticlePreview(
            id: bp_subsection_id,
            title: bp_subsection_title,
            intro: bp_subsection_intro,
            mediaName: media_name,
            visitCount: visit,
            likeCount: likecount,
            platform: bp_subsection_type_type ?? 0,
            clientLike: false,
            clientVisit: false,
            clientKeep: false
        )
    }
}
