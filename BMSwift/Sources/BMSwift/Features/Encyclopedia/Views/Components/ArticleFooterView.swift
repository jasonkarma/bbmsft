#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleFooterView: View {
    let article: ArticleDetailResponse
    let token: String
    let comments: [Comment]
    @ObservedObject var viewModel: ArticleDetailViewModel
    var onNavigateToArticle: (Int) -> Void
    private let imageBaseURL: String = "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/small/"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !article.keywords.isEmpty {
                keywordsView
            }
            
            // Comments section always visible
            commentsSection
            
            if !article.suggests.isEmpty {
                suggestionsSection
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
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("留言")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !comments.isEmpty {
                    Text("\(comments.count) 篇留言")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            if !comments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(comments, id: \.created_at) { comment in
                            commentCard(comment)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Comment input always visible
            commentInput
                .padding(.horizontal)
        }
    }
    
    private func commentCard(_ comment: Comment) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(comment.user_name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(comment.cnt)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Text(comment.created_at)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 150)
        .padding()
        .background(Color.gray.opacity(0.5))
        .cornerRadius(12)
    }
    
    private var commentInput: some View {
        VStack(spacing: 8) {
            TextField("請輸入留言", text: $viewModel.commentText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(AppColors.primary)
            
            Button {
                Task {
                    await viewModel.submitComment()
                }
            } label: {
                Text("發佈")
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .disabled(viewModel.commentText.isEmpty)
        }
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("您可能也會感興趣！")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(article.suggests) { suggestion in
                        SuggestionCardView(
                            suggestion: suggestion,
                            token: token,
                            onTap: onNavigateToArticle
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct SuggestionCardView: View {
    let suggestion: ArticleDetailResponse.Suggestion
    let token: String
    var onTap: (Int) -> Void
    private let imageBaseURL: String = "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/"
    
    var body: some View {
        Button {
            onTap(suggestion.bp_subsection_id)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Top - Image
                suggestionImageView
                
                // Bottom - Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.bp_subsection_title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(suggestion.bp_subsection_intro)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
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
    
    private func logSuggestionDebug(_ suggestion: ArticleDetailResponse.Suggestion) {
        print("\n📋 Suggestion Debug:")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🆔 ID:                \(suggestion.bp_subsection_id)")
        print("📝 Title:             \(suggestion.bp_subsection_title)")
        print("📄 Intro:             \(suggestion.bp_subsection_intro)")
        print("👤 Name:              \(suggestion.name)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
    
    private func logImageDebug(baseURL: String, encodedName: String, fullURL: String) {
        print("\n📸 Image URL Construction Debug:")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔗 Base URL:          \(baseURL)")
        print("🔒 Encoded Name:      \(encodedName)")
        print("🌐 Full URL:          \(fullURL)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
    
    private var suggestionImageView: some View {
        Group {
            if let imageUrl = URL(string: "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/\(suggestion.name)") {
                AuthenticatedAsyncImage(url: imageUrl, token: token) { phase in
                    switch phase {
                    case .empty:
                        Color.gray
                            .frame(height: 120)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    case .failure:
                        Color.gray
                            .frame(height: 120)
                    @unknown default:
                        Color.gray
                            .frame(height: 120)
                    }
                }
            } else {
                Color.gray
                    .frame(height: 120)
                    .onAppear {
                        print("❌ Invalid image URL: https://wiki.kinglyrobot.com/media/beauty_content_banner_image/\(suggestion.name)")
                    }
            }
        }
    }
}

extension ArticleDetailResponse.Suggestion: Identifiable {
    public var id: Int {
        return bp_subsection_id
    }
}
#endif
