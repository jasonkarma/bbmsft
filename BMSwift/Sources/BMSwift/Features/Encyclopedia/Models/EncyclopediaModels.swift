import Foundation

// MARK: - Encyclopedia Content Models
@available(iOS 13.0, *)
public struct ArticlePreview: Codable, Hashable, Identifiable, ArticleCardModel {
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        intro = try container.decode(String.self, forKey: .intro)
        mediaName = try container.decode(String.self, forKey: .mediaName)
        visitCount = try container.decode(Int.self, forKey: .visitCount)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        platform = try container.decode(Int.self, forKey: .platform)
        
        // Convert integer values to booleans
        let clientLikeInt = try container.decode(Int.self, forKey: .clientLike)
        let clientVisitInt = try container.decode(Int.self, forKey: .clientVisit)
        let clientKeepInt = try container.decode(Int.self, forKey: .clientKeep)
        
        clientLike = clientLikeInt != 0
        clientVisit = clientVisitInt != 0
        clientKeep = clientKeepInt != 0
    }
    
    public init(
        id: Int,
        title: String,
        intro: String,
        mediaName: String,
        visitCount: Int,
        likeCount: Int,
        platform: Int,
        clientLike: Bool,
        clientVisit: Bool,
        clientKeep: Bool
    ) {
        self.id = id
        self.title = title
        self.intro = intro
        self.mediaName = mediaName
        self.visitCount = visitCount
        self.likeCount = likeCount
        self.platform = platform
        self.clientLike = clientLike
        self.clientVisit = clientVisit
        self.clientKeep = clientKeep
    }


    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
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

public struct ArticleClientActions: Codable, Equatable {
    public var keep: Bool?
    public var like: Bool?
    public var visit: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case keep
        case like
        case visit
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        keep = try container.decodeIfPresent(Bool.self, forKey: .keep) ?? false
        like = try container.decodeIfPresent(Bool.self, forKey: .like) ?? false
        visit = try container.decodeIfPresent(Bool.self, forKey: .visit) ?? false
    }
    
    public var isLiked: Bool {
        like ?? false
    }
    
    public var isKept: Bool {
        keep ?? false
    }
    
    public var hasVisited: Bool {
        visit ?? false
    }
}

public struct ArticleResponse: Decodable {
    public let info: ArticleInfo
    public var content: [ArticleContent]
    public let keywords: [ArticleKeyword]
    public let suggests: [ArticlePreview]
    public let chapters: [ArticleChapter]
    public var clientsAction: ArticleClientActions
    
    private enum CodingKeys: String, CodingKey {
        case info
        case content = "cnt"
        case keywords
        case suggests
        case chapters
        case clientsAction
    }
}
