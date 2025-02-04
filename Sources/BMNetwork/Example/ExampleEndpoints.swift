import Foundation

// Example of how to define endpoints with different base URLs
public enum ExampleEndpoints {
    // Auth feature endpoints using auth API
    public struct Login: APIEndpoint {
        public typealias RequestType = LoginRequest
        public typealias ResponseType = LoginResponse
        
        public var baseURL: URL {
            URL(string: "https://auth.example.com")!
        }
        public let path: String = "/api/login"
        public let method: HTTPMethod = .post
    }
    
    // Encyclopedia feature endpoints using wiki API
    public struct GetArticle: APIEndpoint {
        public typealias RequestType = EmptyRequest
        public typealias ResponseType = ArticleResponse
        
        public var baseURL: URL {
            URL(string: "https://wiki.kinglyrobot.com")!
        }
        public let path: String
        public let method: HTTPMethod = .get
        
        public init(articleId: String) {
            self.path = "/api/articles/\(articleId)"
        }
    }
    
    // Analytics feature endpoints using analytics API
    public struct TrackEvent: APIEndpoint {
        public typealias RequestType = AnalyticsEvent
        public typealias ResponseType = EmptyResponse
        
        public var baseURL: URL {
            URL(string: "https://analytics.example.com")!
        }
        public let path: String = "/api/track"
        public let method: HTTPMethod = .post
    }
}

// Example request/response types
public struct LoginRequest: Codable {
    public let email: String
    public let password: String
}

public struct LoginResponse: Codable {
    public let token: String
}

public struct ArticleResponse: Codable {
    public let title: String
    public let content: String
}

public struct AnalyticsEvent: Codable {
    public let name: String
    public let properties: [String: String]
}

public struct EmptyRequest: Codable {}
public struct EmptyResponse: Codable {}
