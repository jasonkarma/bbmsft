import Foundation


public enum VoiceSearch {
    // MARK: - Voice Search Response Models
    public struct SearchResponse: Codable {
        public let normalSuggestion: Bool
        public let contents: Contents
        
        public struct Contents: Codable {
            public let currentPage: Int
            public let data: [Search.SearchArticle]
            public let firstPageUrl: String
            public let from: Int
            public let lastPage: Int
            public let lastPageUrl: String
            public let links: [PageLink]
            public let nextPageUrl: String?
            public let path: String
            public let perPage: Int
            public let prevPageUrl: String?
            public let to: Int
            public let total: Int
            
            private enum CodingKeys: String, CodingKey {
                case currentPage = "current_page"
                case data
                case firstPageUrl = "first_page_url"
                case from
                case lastPage = "last_page"
                case lastPageUrl = "last_page_url"
                case links
                case nextPageUrl = "next_page_url"
                case path
                case perPage = "per_page"
                case prevPageUrl = "prev_page_url"
                case to
                case total
            }
        }
        
        public struct PageLink: Codable {
            public let url: String?
            public let label: String
            public let active: Bool
        }
    }
}
