import Foundation

// MARK: - Article Detail Response
public struct ArticleDetailResponse: Codable {
    public let info: Info
    public let cnt: [Content]
    public let keywords: [Keyword]
    public let suggests: [Suggestion]
    public let chapters: [Chapter]
    public let clientsAction: ClientsAction
    
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
    }
    
    public struct Keyword: Codable {
        public let bp_hashtag: String
        public let bp_tag_id: Int
    }
    
    public struct Suggestion: Codable {
        public let bp_subsection_id: Int
        public let bp_subsection_title: String
        public let bp_subsection_intro: String
        public let name: String
    }
    
    public struct Chapter: Codable {
        public let bp_chapter_id: Int
        public let bp_chapter_name: String
    }
    
    public struct ClientsAction: Codable {
        public let keep: Bool
        public let like: Bool
    }
}

// MARK: - Comment Models
public struct Comment: Codable {
    public let cnt: String
    public let bestcmt: Bool?
    public let state: Int
    public let user_name: String
    public let created_at: String
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
}

// MARK: - Client Action Models
public struct ClientActionRequest: Codable {
    public let bp_subsection_id: Int
    
    public init(bp_subsection_id: Int) {
        self.bp_subsection_id = bp_subsection_id
    }
}

public struct ClientActionResponse: Codable {
    public let message: String
}
