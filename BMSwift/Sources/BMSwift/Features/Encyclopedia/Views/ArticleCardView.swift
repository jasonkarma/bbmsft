#if canImport(SwiftUI)
import SwiftUI

public struct ArticleCardView: View {
    private let article: ArticlePreview
    private let imageBaseURL = "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/small/"
    
    public init(article: ArticlePreview) {
        self.article = article
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left side - Image
            if let url = URL(string: imageBaseURL + article.mediaName) {
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
            }
            
            // Right side - Content
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(Color(red: 58/255, green: 181/255, blue: 151/255))
                    .lineLimit(2)
                
                Text(article.intro)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding(.all, 8)
        }
        .background(Color.black)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(radius: 4)
    }
}
#endif
