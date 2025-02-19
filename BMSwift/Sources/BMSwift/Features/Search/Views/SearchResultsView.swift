import SwiftUI


public extension BMSearchV2.Search {
    struct SearchResultsView: View {
        public let results: [SearchResponse.SearchArticle]
        public let token: String
        
        public init(results: [SearchResponse.SearchArticle], token: String) {
            self.results = results
            self.token = token
        }
        
        public var body: some View {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(results) { article in
                        ArticleCardView(article: article, token: token) {
                            // TODO: Handle article tap
                        }
                    }
                }
                .padding()
                .onChange(of: results) { newResults in
                    // Post notification to replace hot articles
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ReplaceHotArticles"),
                        object: nil,
                        userInfo: ["articles": newResults]
                    )
                }
            }
            .background(AppColors.black.swiftUIColor)
        }
    }
}

#if DEBUG
@available(iOS 13.0, *)
struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        BMSearchV2.Search.SearchResultsView(
            results: [
                BMSearchV2.Search.SearchResponse.SearchArticle(
                    bp_subsection_id: 1,
                    bp_subsection_title: "Preview Article 1",
                    bp_subsection_intro: "This is a preview article for testing",
                    bp_subsection_first_enabled_at: "2024-01-01",
                    media_name: "https://example.com/image1.jpg",
                    visit: 100,
                    likecount: 50,
                    hashtag: [],
                    content_type: nil,
                    bp_subsection_type_type: 1,
                    bp_subsection_type_title: "Type 1",
                    bp_subsection_type_cnt: "Content 1"
                ),
                BMSearchV2.Search.SearchResponse.SearchArticle(
                    bp_subsection_id: 2,
                    bp_subsection_title: "Preview Article 2",
                    bp_subsection_intro: "Another preview article for testing",
                    bp_subsection_first_enabled_at: "2024-01-02",
                    media_name: "https://example.com/image2.jpg",
                    visit: 200,
                    likecount: 75,
                    hashtag: [],
                    content_type: nil,
                    bp_subsection_type_type: 1,
                    bp_subsection_type_title: "Type 1",
                    bp_subsection_type_cnt: "Content 2"
                )
            ],
            token: "preview-token"
        )
    }
}
#endif
