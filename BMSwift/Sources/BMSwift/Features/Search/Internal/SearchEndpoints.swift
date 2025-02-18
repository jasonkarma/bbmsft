import Foundation

/// Empty request type for endpoints that don't need request body
public struct EmptyRequest: Codable {
    public init() {}
}

@available(iOS 13.0, *)
public extension BMSearchV2.Keywords {
    /// Hot keywords endpoint
    struct HotKeywordsEndpoint: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = HotKeywordsResponse
        
        public let path = "/api/beauty/hotKeyword"
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        
        public init(authToken: String) {
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
    }
    
    /// All keywords endpoint
    struct AllKeywordsEndpoint: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = AllKeywordsResponse
        
        public let path = "/api/beauty/keyword"
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        
        public init(authToken: String) {
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
    }
}

@available(iOS 13.0, *)
public extension BMSearchV2.Search {
    /// Search article results endpoint
    struct SearchEndpoint: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = SearchResponse
        
        private let type: SearchType
        private let bpTagId: String
        private let page: Int
        
        public let path: String = "/api/beauty/searchContent"
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = true
        public let headers: [String: String]
        public let baseURL: URL? = nil
        
        public init(type: SearchType, bpTagId: String, page: Int, authToken: String) {
            self.type = type
            self.bpTagId = bpTagId
            self.page = page
            self.headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(authToken)"
            ]
        }
        
        public var queryItems: [URLQueryItem]? {
            [
                URLQueryItem(name: "type", value: String(type.rawValue)),
                URLQueryItem(name: "input", value: bpTagId),
                URLQueryItem(name: "page", value: String(page))
            ]
        }
    }
}
