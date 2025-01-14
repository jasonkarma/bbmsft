#if canImport(SwiftUI)
import SwiftUI

public struct ArticleCardView: View {
    private let article: ArticlePreview
    private let imageBaseURL = "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/"
    
    public init(article: ArticlePreview) {
        self.article = article
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let url = URL(string: imageBaseURL + article.mediaName) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipped()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(article.intro)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Label("\(article.visitCount)", systemImage: "eye")
                    Label("\(article.likeCount)", systemImage: "heart")
                    Spacer()
                    if article.clientKeep {
                        Image(systemName: "bookmark.fill")
                    }
                    if article.clientLike {
                        Image(systemName: "heart.fill")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
#endif
