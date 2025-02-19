import Foundation

public enum Search {
        // MARK: - Search Response Models
        /// Response from content search endpoint
        public struct SearchResponse: Codable {
            public let currentPage: Int
            public let data: [SearchArticle]
            public let total: Int
            
            private enum CodingKeys: String, CodingKey {
                case currentPage = "current_page"
                case data
                case total
            }
            
            var contents: SearchContents {
                .init(currentPage: currentPage, data: data, total: total)
            }
        }
    
        /// Contents pagination data
        public struct SearchContents {
            public let currentPage: Int
            public let data: [SearchArticle]
            public let total: Int
        }
    
        /// Article data from search response
        public struct SearchArticle: Codable, ArticleDisplayable, Equatable {
            public let id: Int
            public let title: String
            public let intro: String
            public let mediaName: String
            public let visitCount: Int
            public let likeCount: Int
            public let firstEnabledAt: String
            public let hashtags: [Hashtag]
            
            // Additional fields for type=1+
            public let typeType: Int?
            public let typeTitle: String?
            public let typeContent: String?
        
            private enum CodingKeys: String, CodingKey {
                case id = "bp_subsection_id"
                case title = "bp_subsection_title"
                case intro = "bp_subsection_intro"
                case mediaName = "media_name"
                case visitCount = "visit"
                case likeCount = "likecount"
                case firstEnabledAt = "bp_subsection_first_enabled_at"
                case hashtags = "hashtag"
                case typeType = "bp_subsection_type_type"
                case typeTitle = "bp_subsection_type_title"
                case typeContent = "bp_subsection_type_cnt"
            }
    }
    
    /// Hashtag data
        public struct Hashtag: Codable, Equatable {
            public let id: Int
            public let hashtag: String
        
            private enum CodingKeys: String, CodingKey {
                case id = "bp_tag_id"
                case hashtag = "bp_hashtag"
            }
    }
}

