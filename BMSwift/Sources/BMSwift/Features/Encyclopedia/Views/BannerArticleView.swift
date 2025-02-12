#if canImport(SwiftUI) && os(iOS)
import SwiftUI




@available(iOS 13.0, *)
struct BannerArticleView: View {
    private let articles: [ArticlePreview]
    private let imageBaseURL = "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/small/"
    @State private var offset: CGFloat = 0
    let onNavigateToArticle: (ArticlePreview) -> Void
    
    init(articles: [ArticlePreview], onNavigateToArticle: @escaping (ArticlePreview) -> Void) {
        self.articles = articles
        self.onNavigateToArticle = onNavigateToArticle
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(articles, id: \.id) { article in
                    Button(action: {
                        onNavigateToArticle(article)
                    }) {
                        VStack(spacing: 4) {
                            if let url = URL(string: imageBaseURL + article.mediaName) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .bmForegroundColor(AppColors.secondaryBg.opacity(0.2))
                                }
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                            }
                            
                            Text(article.title)
                                .font(.caption)
                                .bmForegroundColor(AppColors.primary)
                                .lineLimit(2)
                                .frame(width: 100)
                        }
                        .frame(width: 100, height: 150)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 150)
        .bmBackground(AppColors.black)
    }
}

#if DEBUG
struct BannerArticleView_Previews: PreviewProvider {
    static var previews: some View {
        BannerArticleView(
            articles: [
                ArticlePreview(id: 1, 
                             title: "Preview Article", 
                             intro: "Preview intro",
                             mediaName: "preview.jpg",
                             visitCount: 0,
                             likeCount: 0,
                             platform: 1,
                             clientLike: false,
                             clientVisit: false,
                             clientKeep: false)
            ],
            onNavigateToArticle: { _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif
#endif
