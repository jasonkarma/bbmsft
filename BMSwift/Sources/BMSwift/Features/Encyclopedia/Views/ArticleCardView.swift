#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public struct ArticleCardView: View {
    private let article: ArticlePreview
    private let token: String
    private let imageBaseURL: String = "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/small/"
    
    public init(article: ArticlePreview, token: String) {
        self.article = article
        self.token = token
    }
    
    public var body: some View {
        NavigationLink(destination: ArticleDetailView(viewModel: ArticleDetailViewModel(articleId: article.id, token: token))) {
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
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .bmStroke(AppColors.secondaryText.opacity(0.5), lineWidth: 1.5)
            )
            .shadow(radius: 4)
        }
        .buttonStyle(.plain)
    }
}
#endif
