#if canImport(SwiftUI)
import SwiftUI

struct BannerArticleView: View {
    private let articles: [ArticlePreview]
    private let imageBaseURL = "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/small/"
    @State private var offset: CGFloat = 0
    
    init(articles: [ArticlePreview]) {
        self.articles = articles
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(articles.indices, id: \.self) { index in
                    VStack(spacing: 4) {
                        if let url = URL(string: imageBaseURL + articles[index].mediaName) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.2))
                            }
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                        }
                        
                        Text(articles[index].title)
                            .font(.caption)
                            .foregroundColor(Color(red: 58/255, green: 181/255, blue: 151/255))
                            .lineLimit(2)
                            .frame(width: 100)
                    }
                    .frame(width: 100, height: 150)
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 150)
        .background(Color.black)
    }
}
#endif
