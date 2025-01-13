#if canImport(SwiftUI)
import SwiftUI

public struct ArticleCardView: View {
    let article: ArticlePreview
    let onTap: () -> Void
    
    public init(article: ArticlePreview, onTap: @escaping () -> Void) {
        self.article = article
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Article image
                AsyncImage(url: URL(string: "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/\(article.media_name)")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                }
                
                // Article content
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.bp_subsection_title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(BMSwift.AppColors.primary)
                        .lineLimit(2)
                    
                    Text(article.bp_subsection_intro)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
                .padding(.trailing, 8)
            }
            .background(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary, lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
#endif
