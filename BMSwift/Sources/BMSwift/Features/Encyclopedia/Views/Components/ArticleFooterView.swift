#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleFooterView: View {
    let article: ArticleDetailResponse
    let comments: [Comment]
    @ObservedObject var viewModel: ArticleDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !article.keywords.isEmpty {
                keywordsView
            }
            
            if !comments.isEmpty {
                commentsSection
            }
            
            if !article.suggests.isEmpty {
                suggestedArticlesView
            }
        }
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
        }
    }
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comments")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(comments, id: \.created_at) { comment in
                commentView(comment)
            }
            
            commentInput
        }
    }
    
    private func commentView(_ comment: Comment) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(comment.user_name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text(comment.cnt)
                .font(.body)
                .foregroundColor(.primary)
            Text(comment.created_at)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var commentInput: some View {
        HStack {
            TextField("Add a comment...", text: $viewModel.commentText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Post") {
                Task {
                    await viewModel.submitComment()
                }
            }
            .disabled(viewModel.commentText.isEmpty)
        }
    }
    
    private var suggestedArticlesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Articles")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(article.suggests, id: \.bp_subsection_id) { suggestion in
                suggestionView(suggestion)
            }
        }
    }
    
    private func suggestionView(_ suggestion: ArticleDetailResponse.Suggestion) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(suggestion.bp_subsection_title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text(suggestion.bp_subsection_intro)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
#endif
