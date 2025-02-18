#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ArticleCardView: View {
    private let article: ArticleCardModel
    private let token: String
    private let onTap: () -> Void
    private let imageBaseURL: String = "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/small/"
    
    public init(article: ArticleCardModel, token: String, onTap: @escaping () -> Void) {
        self.article = article
        self.token = token
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 0) {
                // Left side - Image
                if let url = URL(string: imageBaseURL + article.mediaName) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .bmFill(AppColors.secondaryBg)
                    }
                    .frame(width: 100, height: 100)
                    .clipped()
                }
                
                // Right side - Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.headline)
                        .bmForegroundColor(AppColors.primary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(article.intro)
                        .font(.subheadline)
                        .bmForegroundColor(AppColors.secondaryText)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 0)
                }
                .padding(.all, 8)
                .frame(height: 100)
            }
            .frame(height: 100)
            .bmBackground(AppColors.black)
            .cornerRadius(8)
        }
    }
}

#if DEBUG
public struct ArticleCardView_Previews: PreviewProvider {
    public struct PreviewArticle: ArticleCardModel {
        public let id: Int = 1
        public let title: String = "Preview Title"
        public let intro: String = "This is a preview of the article card with some longer text to see how it handles multiple lines."
        public let mediaName: String = "preview.jpg"
    }
    
    public static var previews: some View {
        ArticleCardView(
            article: PreviewArticle(),
            token: "preview-token",
            onTap: {}
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
#endif
