import Foundation

// MARK: - Encyclopedia Content Models
public struct ArticlePreview: Codable, Hashable {
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
        case id = "bpSubsectionId"
        case title = "bpSubsectionTitle"
        case intro = "bpSubsectionIntro"
        case mediaName = "mediaName"
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
    
    private enum CodingKeys: String, CodingKey {
        case hotContents
        case latestContents
    }
    
    public init(from decoder: Decoder) throws {
        // The response is a top-level array that we need to decode as a dictionary
        let container = try decoder.singleValueContainer()
        let responseDict = try container.decode([String: [ArticlePreview]].self)
        
        // Get arrays with nil coalescing for missing keys
        hotContents = responseDict["hotContents"] ?? []
        latestContents = responseDict["latestContents"] ?? []
    }
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
        case hashtag = "bpHashtag"
        case tagId = "bpTagId"
    }
}

public struct ArticleChapter: Codable {
    public let id: Int
    public let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "bpChapterId"
        case name = "bpChapterName"
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
        case id = "bpSubsectionId"
        case title = "bpSubsectionTitle"
        case platform
        case intro = "bpSubsectionIntro"
        case mediaName = "name"
        case state = "bpSubsectionState"
        case visitCount = "visit"
        case firstEnabledAt = "bpSubsectionFirstEnabledAt"
        case likeCount = "likecount"
    }
}

public struct ArticleClientActions: Codable {
    public let keep: Bool
    public let like: Bool
    public let visit: Bool
    
    private enum CodingKeys: String, CodingKey {
        case keep
        case like
        case visit
    }
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
