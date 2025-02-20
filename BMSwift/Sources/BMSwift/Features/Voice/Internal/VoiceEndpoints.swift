import Foundation
/// Response type for KNN API - handles array response [text, confidence, otherScore]
public struct KNNResponse: Codable {
    public let text: String           // The keyword text like "美容api藍光"
    public let confidence: Double     // First score like 0.51
    public let otherScore: Double    // Second score like 0.06
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        text = try container.decode(String.self)
        confidence = try container.decode(Double.self)
        otherScore = try container.decode(Double.self)
    }
    
    /// Extract the keyword after 'api' from the text
    public var extractedKeyword: String? {
        let parts = text.split(separator: "api", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count > 1 else { return nil }
        return String(parts[1]).trimmingCharacters(in: .whitespaces)
    }
}

/// Endpoints for the Voice feature
public enum VoiceEndpoints {
    /// Empty request type for endpoints that don't need request body
    public struct EmptyRequest: Codable {
        public init() {}
    }
    
    /// KNN API endpoint for getting search keywords from voice text
    public struct KNNSearch: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = KNNResponse
        
        // Override default base URL to use KNN API
        public var baseURL: URL? { URL(string: "https://gptbot.kinglyrobot.com") }
        public let path: String = "/KNN/api/"
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = false
        public let headers: [String: String] = [:]
        
        public var queryItems: [URLQueryItem]? {
            [
                URLQueryItem(name: "name", value: "BeautyKey_zh-TW"),
                URLQueryItem(name: "id", value: voiceText)
            ]
        }
        
        private let voiceText: String
        
        public init(voiceText: String) {
            print("DEBUG: Original voice text: \(voiceText)")
            self.voiceText = voiceText
        }
    }
    
    /// Response type for content search
    public struct SearchResponse: Codable {
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
        public let to: Int?
        public let total: Int
        
        // For compatibility with existing code
        public var contents: Contents { Contents(data: data) }
        
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
        
        public struct Contents {
            public let data: [SearchArticle]
        }
        
        public struct SearchArticle: Codable {
            public let id: Int
            public let title: String
            public let intro: String
            public let firstEnabledAt: String
            public let mediaName: String
            public let visitCount: Int
            public let likeCount: Int
            public let hashtags: [Hashtag]
            public let contentTypes: [ContentType]?
            public let platform: Int?
            public let clientLike: Bool?
            public let clientVisit: Bool?
            public let clientKeep: Bool?
            
            private enum CodingKeys: String, CodingKey {
                case id = "bp_subsection_id"
                case title = "bp_subsection_title"
                case intro = "bp_subsection_intro"
                case firstEnabledAt = "bp_subsection_first_enabled_at"
                case mediaName = "media_name"
                case visitCount = "visit"
                case likeCount = "likecount"
                case hashtags = "hashtag"
                case contentTypes = "content_type"
                case platform
                case clientLike = "client_like"
                case clientVisit = "client_visit"
                case clientKeep = "client_keep"
            }
        }
        
        public struct Hashtag: Codable {
            public let id: Int
            public let tag: String
            public let throughKey: Int
            
            private enum CodingKeys: String, CodingKey {
                case id = "bp_tag_id"
                case tag = "bp_hashtag"
                case throughKey = "laravel_through_key"
            }
        }
        
        public struct ContentType: Codable {
            public let type: Int
            public let title: String
            public let content: String
            
            private enum CodingKeys: String, CodingKey {
                case type = "bp_subsection_type_type"
                case title = "bp_subsection_type_title"
                case content = "bp_subsection_type_cnt"
            }
        }
    }
    
    /// Content hashtag endpoint for getting search results
    public struct ContentHashtag: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = SearchResponse
        
        public var baseURL: URL? { URL(string: "https://wiki.kinglyrobot.com") }
        public let path: String = "/api/beauty/searchContent"
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = false
        public let headers: [String: String] = [:]
        public let queryItems: [URLQueryItem]?
        
        public init(searchText: String) {
            self.queryItems = [
                URLQueryItem(name: "type", value: "0"),
                URLQueryItem(name: "input", value: searchText)
            ]
        }
    }
    


}
