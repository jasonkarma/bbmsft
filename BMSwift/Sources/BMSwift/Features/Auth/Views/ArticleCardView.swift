import SwiftUI
import BMSwift

public struct ArticleCardView: View {
    let article: ArticlePreview
    let onTap: () -> Void
    
    public init(article: ArticlePreview, onTap: @escaping () -> Void) {
        self.article = article
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Article image
                AsyncImage(url: URL(string: "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/\(article.media_name)")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Article text content
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.bp_subsection_title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(article.bp_subsection_intro)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
