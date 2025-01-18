#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleFooterView: View {
    let article: ArticleDetailResponse
    let token: String
    let comments: [Comment]
    @ObservedObject var viewModel: ArticleDetailViewModel
    let onNavigateToArticle: @MainActor (Int) async -> Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Keywords section
            if !article.keywords.isEmpty {
                keywordsView
            }
            
            // Suggestions section
            if !article.suggests.isEmpty {
                suggestionsSection
            }
            
            // Comments section
            if !comments.isEmpty {
                commentsSection
            }
        }
        .padding(.vertical)
    }
    
    private var keywordsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(article.keywords, id: \.bp_tag_id) { keyword in
                    Text("#\(keyword.bp_hashtag)")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("查看更多美容攻略！")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(article.suggests, id: \.bp_subsection_id) { suggestion in
                        SuggestionCardView(
                            suggestion: suggestion,
                            token: token,
                            onTap: onNavigateToArticle
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("评论")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(comments, id: \.created_at) { comment in
                VStack(alignment: .leading, spacing: 8) {
                    Text(comment.user_name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(comment.cnt)
                        .font(.body)
                        .lineLimit(3)
                    Text(comment.created_at)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
    }
}

private struct SuggestionCardView: View {
    let suggestion: ArticleDetailResponse.Suggestion
    let token: String
    let onTap: @MainActor (Int) async -> Bool
    
    var body: some View {
        Button {
            Task {
                let _ = await onTap(suggestion.bp_subsection_id)
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Top - Image
                Group {
                    if let imageUrl = URL(string: "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/\(suggestion.name)") {
                        AuthenticatedAsyncImage(url: imageUrl, token: token) { phase in
                            switch phase {
                            case .empty:
                                Color.gray
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Color.gray
                            @unknown default:
                                Color.gray
                            }
                        }
                    } else {
                        Color.gray
                    }
                }
                .frame(width: 120, height: 120)
                .clipped()
                
                // Bottom - Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.bp_subsection_title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(suggestion.bp_subsection_intro)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                .frame(width: 96)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(height: 80)
            }
            .frame(width: 120)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}
#endif
