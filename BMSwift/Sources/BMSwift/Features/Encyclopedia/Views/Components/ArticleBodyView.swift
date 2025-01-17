#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleBodyView: View {
    let article: ArticleDetailResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Introduction section
            ArticleContentView(htmlContent: article.info.bp_subsection_intro)
                .id("intro_\(article.info.bp_subsection_id)")
                .padding(.bottom, 8)
            
            // Article image if available
            if !article.info.name.isEmpty {
                articleImage
                    .padding(.vertical, 8)
            }
            
            // Main content sections
            ForEach(article.cnt, id: \.title) { content in
                VStack(alignment: .leading, spacing: 8) {
                    if !content.title.isEmpty {
                        Text(content.title)
                            .font(.headline)
                            .foregroundColor(AppColors.primary)
                    }
                    ArticleContentView(htmlContent: content.cnt)
                        .id("content_\(content.title)")
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var articleImage: some View {
        AsyncImage(url: URL(string: "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/\(article.info.name)")) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(height: 200)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .shadow(radius: 2)
            case .failure:
                Color.gray.opacity(0.3)
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            @unknown default:
                EmptyView()
            }
        }
        .id("image_\(article.info.bp_subsection_id)")
    }
}
#endif
