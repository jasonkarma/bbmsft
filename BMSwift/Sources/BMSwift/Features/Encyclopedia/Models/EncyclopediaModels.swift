import Foundation

// MARK: - Encyclopedia Content Models
public struct ArticlePreview: Codable {
    public let id: Int
    public let title: String
    public let intro: String
    public let mediaName: String
    public let visitCount: Int
    public let likeCount: Int
    public let platform: Int
    public let clientLike: Bool
    public let clientVisit: Bool
    public let clientKeep: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id = "bp_subsection_id"
        case title = "bp_subsection_title"
        case intro = "bp_subsection_intro"
        case mediaName = "media_name"
        case visitCount = "visit"
        case likeCount = "likecount"
        case platform
        case clientLike = "clientlike"
        case clientVisit = "clientvisit"
        case clientKeep = "clientkeep"
    }
}

public struct FrontPageResponse: Decodable {
    public let hotContents: [ArticlePreview]
    public let latestContents: [ArticlePreview]
}

public struct ArticleContent: Codable {
    public let type: Int
    public let title: String
    public let content: String
    
    private enum CodingKeys: String, CodingKey {
        case type
        case title
        case content = "cnt"
    }
}

public struct ArticleKeyword: Codable {
    public let hashtag: String
    public let tagId: Int
    
    private enum CodingKeys: String, CodingKey {
        case hashtag = "bp_hashtag"
        case tagId = "bp_tag_id"
    }
}

public struct ArticleChapter: Codable {
    public let id: Int
    public let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "bp_chapter_id"
        case name = "bp_chapter_name"
    }
}

public struct ArticleInfo: Codable {
    public let id: Int
    public let title: String
    public let platform: Int
    public let intro: String
    public let mediaName: String
    public let state: Int
    public let visitCount: Int
    public let firstEnabledAt: Date
    public let likeCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "bp_subsection_id"
        case title = "bp_subsection_title"
        case platform
        case intro = "bp_subsection_intro"
        case mediaName = "name"
        case state = "bp_subsection_state"
        case visitCount = "visit"
        case firstEnabledAt = "bp_subsection_first_enabled_at"
        case likeCount = "likecount"
    }
}

public struct ArticleClientActions: Codable {
    public let keep: Bool
    public let like: Bool
}

public struct ArticleResponse: Decodable {
    public let info: ArticleInfo
    public let content: [ArticleContent]
    public let keywords: [ArticleKeyword]
    public let suggests: [ArticlePreview]
    public let chapters: [ArticleChapter]
    public let clientsAction: ArticleClientActions
    
    private enum CodingKeys: String, CodingKey {
        case info
        case content = "cnt"
        case keywords
        case suggests
        case chapters
        case clientsAction = "clientsAction"
    }
}
