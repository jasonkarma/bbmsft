import Foundation

// MARK: - Search Response Models
public struct SearchResponse: Decodable {
    public let currentPage: Int
    public let data: [SearchArticle]
    public let firstPageUrl: String?
    public let from: Int?
    public let lastPage: Int
    public let lastPageUrl: String?
    public let nextPageUrl: String?
    public let path: String
    public let perPage: Int
    public let prevPageUrl: String?
    public let to: Int?
    public let total: Int
    
    private enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageUrl = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageUrl = "last_page_url"
        case nextPageUrl = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageUrl = "prev_page_url"
        case to
        case total
    }
}

public struct SearchContents: Decodable {
    public let currentPage: Int
    public let data: [SearchArticle]
    public let firstPageUrl: String
    public let from: Int
    public let lastPage: Int
    public let lastPageUrl: String
    public let nextPageUrl: String?
    public let path: String
    public let perPage: Int
    public let prevPageUrl: String?
    public let to: Int
    public let total: Int
    public let links: [PageLink]
    
    private enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageUrl = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageUrl = "last_page_url"
        case nextPageUrl = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageUrl = "prev_page_url"
        case to
        case total
        case links
    }
}

public struct PageLink: Decodable {
    public let url: String?
    public let label: String
    public let active: Bool
}

public struct SearchArticle: Decodable, Identifiable {
    // Common fields for both type 0 and type 1+
    public let bp_subsection_id: Int
    public let bp_subsection_title: String
    public let bp_subsection_intro: String?
    public let bp_subsection_first_enabled_at: String
    public let media_name: String
    public let visit: Int
    public let likecount: Int
    public let hashtag: [HashTag]
    
    // Type 0 specific field
    public let content_type: [ContentType]?
    
    // Type 1+ specific fields
    public let bp_subsection_type_type: Int?
    public let bp_subsection_type_title: String?
    public let bp_subsection_type_cnt: String?
    
    // Identifiable conformance
    public var id: Int { bp_subsection_id }
    
    private enum CodingKeys: String, CodingKey {
        case bp_subsection_id
        case bp_subsection_title
        case bp_subsection_intro
        case bp_subsection_first_enabled_at
        case media_name
        case visit
        case likecount
        case hashtag
        case content_type
        case bp_subsection_type_type
        case bp_subsection_type_title
        case bp_subsection_type_cnt
    }
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
