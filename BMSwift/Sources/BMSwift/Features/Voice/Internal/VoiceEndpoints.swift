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
        if let range = text.range(of: "api") {
            return String(text[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        }
        return nil
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
        public let contents: Contents
        
        public struct Contents: Codable {
            public let data: [SearchArticle]
        }
        
        public struct SearchArticle: Codable {
            public let id: Int
            public let title: String
            public let intro: String
            public let mediaName: String
            public let visitCount: Int
            public let likeCount: Int
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
