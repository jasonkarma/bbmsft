import Foundation

/// Endpoints for the Search feature
public enum SearchEndpoints {
    /// Empty request type for endpoints that don't need request body
    public struct EmptyRequest: Codable {
        public init() {}
    }
    
    /// Content search by hashtag and type endpoint
    public struct ContentSearch: BMNetwork.APIEndpoint {
            public typealias RequestType = EmptyRequest?
            public typealias ResponseType = Search.SearchResponse
            
            public let path: String
            public let method: BMNetwork.HTTPMethod = .get
            public let requiresAuth: Bool = true
            public let headers: [String: String]
            public let baseURL: URL? = nil
        
            public init(tagId: Int, type: Int, authToken: String) {
                self.path = "/api/contentHashtag/\(tagId)?type=\(type)"
                self.headers = [
                    "Accept": "application/json"
                ]
            }
    }
    
    // MARK: - Factory Methods
    public static func contentSearch(tagId: Int, type: Int, authToken: String) -> BMNetwork.APIRequest<ContentSearch> {
        .init(endpoint: ContentSearch(tagId: tagId, type: type, authToken: authToken), authToken: authToken)
    }
}
