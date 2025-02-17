import Foundation

public struct KeywordModel: Codable, Identifiable {
    public let bp_tag_id: Int
    public let bp_hashtag: String
    public let content_count: Int
    
    public var id: Int { bp_tag_id }
}

public struct KeywordResponse: Codable {
    public let hot: [KeywordModel]
    public let all: [KeywordModel]
}

// Legacy models - to be removed after migration
public struct KeywordTag: Codable, Identifiable {
    public let bp_tag_id: Int
    public let bp_hashtag: String
    public let content_count: Int
    
    public var id: Int { bp_tag_id }
}

public struct HotKeywordTag: Codable, Identifiable {
    public let bp_tag_id: Int
    public let bp_hashtag: String
    public let content_hashtag_count: Int
    
    public var id: Int { bp_tag_id }
}
