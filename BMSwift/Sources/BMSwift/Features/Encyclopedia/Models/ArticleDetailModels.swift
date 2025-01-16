#if swift(>=5.0)
// Disable identifier warnings for this file since we need to match API names
#warning("Ignoring identifier naming warnings to match API response format")
#endif

// swiftlint:disable identifier_name
import Foundation

// MARK: - Article Detail Response
public struct ArticleDetailResponse: Codable {
    public let info: Info
    public let cnt: [Content]
    public let keywords: [Keyword]
    public let suggests: [Suggestion]
    public let chapters: [Chapter]
    public let clientsAction: ClientActions
    
    private enum CodingKeys: String, CodingKey {
        case info
        case cnt
        case keywords
        case suggests
        case chapters
        case clientsAction
    }
    
    public struct Info: Codable {
        public let bp_subsection_id: Int
        public let bp_subsection_title: String
        public let platform: Int
        public let bp_subsection_intro: String
        public let name: String
        public let bp_subsection_state: Int
        public let visit: Int
        public let bp_subsection_first_enabled_at: String
        public let likecount: Int
        
        private enum CodingKeys: String, CodingKey {
            case bp_subsection_id
            case bp_subsection_title
            case platform
            case bp_subsection_intro
            case name
            case bp_subsection_state
            case visit
            case bp_subsection_first_enabled_at
            case likecount
        }
    }
    
    public struct Content: Codable {
        public let type: Int
        public let title: String
        public let cnt: String
        
        private enum CodingKeys: String, CodingKey {
            case type
            case title
            case cnt
        }
    }
    
    public struct Keyword: Codable {
        public let bp_tag_id: Int
        public let bp_hashtag: String
        
        private enum CodingKeys: String, CodingKey {
            case bp_tag_id
            case bp_hashtag
        }
    }
    
    public struct Suggestion: Codable {
        public let bp_subsection_id: Int
        public let bp_subsection_title: String
        public let bp_subsection_intro: String
        public let name: String
        
        private enum CodingKeys: String, CodingKey {
            case bp_subsection_id
            case bp_subsection_title
            case bp_subsection_intro
            case name
        }
    }
    
    public struct Chapter: Codable {
        public let bp_chapter_id: Int
        public let bp_chapter_name: String
        
        private enum CodingKeys: String, CodingKey {
            case bp_chapter_id
            case bp_chapter_name
        }
    }
    
    public struct ClientActions: Codable, Equatable {
        public let keep: Bool
        public let like: Bool
        
        private enum CodingKeys: String, CodingKey {
            case keep
            case like
        }
    }
}

// MARK: - Comment Models
public struct Comment: Codable {
    public let cnt: String
    public let bestcmt: Bool?
    public let state: Int
    public let user_name: String
    public let created_at: String
    
    private enum CodingKeys: String, CodingKey {
        case cnt
        case bestcmt
        case state
        case user_name
        case created_at
    }
}

public struct CommentResponse: Codable {
    public let comments: [Comment]
    
    private enum CodingKeys: String, CodingKey {
        case comments
    }
}

public struct CommentRequest: Codable {
    public let bp_subsection_id: Int
    public let cnt: String
    
    public init(bp_subsection_id: Int, cnt: String) {
        self.bp_subsection_id = bp_subsection_id
        self.cnt = cnt
    }
    
    private enum CodingKeys: String, CodingKey {
        case bp_subsection_id
        case cnt
    }
}

// MARK: - Client Action Models
public struct ClientActionRequest: Codable {
    public let bp_subsection_id: Int
    
    public init(bp_subsection_id: Int) {
        self.bp_subsection_id = bp_subsection_id
    }
    
    private enum CodingKeys: String, CodingKey {
        case bp_subsection_id
    }
}

public struct ClientActionResponse: Codable {
    public let message: String
    
    private enum CodingKeys: String, CodingKey {
        case message
    }
}
