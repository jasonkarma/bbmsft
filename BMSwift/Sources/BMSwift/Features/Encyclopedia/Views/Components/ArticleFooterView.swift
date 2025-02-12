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
            // Comments section header and input
            HStack {
                Text("留言")
                    .font(.headline)
                    .bmForegroundColor(AppColors.primary)
                Spacer()
            }
            
            // Comment input area
            VStack(spacing: 12) {
                TextField("請輸入留言", text: $viewModel.commentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .bmForegroundColor(AppColors.primary)
                
                Button(action: {
                    Task {
                        await viewModel.submitComment()
                    }
                }) {
                    Text("發佈")
                        .bmForegroundColor(AppColors.primaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.secondaryBg.swiftUIColor)
                        .cornerRadius(8)
                }
                .disabled(viewModel.commentText.isEmpty)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            // Existing comments display
            if !comments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(comments, id: \.created_at) { comment in
                            if #available(iOS 17.0, *) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(comment.user_name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .bmForegroundColor(AppColors.primary)
                                        .padding(.leading, 8)
                                    Text(comment.cnt)
                                        .font(.body)
                                        .bmForegroundColor(AppColors.primaryText)
                                        .lineLimit(3)
                                        .frame(width: 200)
                                    Text(comment.created_at)
                                        .font(.caption)
                                        .bmForegroundColor(AppColors.secondaryText)
                                        .padding(.leading, 8)
                                }
                                .padding()
                                .frame(width: 200)
                                .background(AppColors.secondaryBg.swiftUIColor)
                                .cornerRadius(12)
                                .shadow(color: AppColors.black.swiftUIColor.opacity(0.5), radius: 4, x: 0, y: 2)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                }
            }
            
            // Keywords section
            if !article.keywords.isEmpty {
                keywordsView
            }
            
            // Suggestions section
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
                        .bmForegroundColor(AppColors.primaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.secondaryBg.swiftUIColor)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("您可能也會感興趣！")
                .font(.headline)
                .bmForegroundColor(AppColors.primary)
            
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
                                AppColors.secondaryBg.swiftUIColor
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                AppColors.secondaryBg.swiftUIColor
                            @unknown default:
                                AppColors.secondaryBg.swiftUIColor
                            }
                        }
                    } else {
                        AppColors.secondaryBg.swiftUIColor
                    }
                }
                .frame(width: 130, height: 120)
                .clipped()
                
                // Bottom - Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.bp_subsection_title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .bmForegroundColor(AppColors.primary)
                        .lineLimit(2)
                    
                    Text(suggestion.bp_subsection_intro)
                        .font(.caption2)
                        .bmForegroundColor(AppColors.secondaryText)
                        .lineLimit(3)
                }
                .frame(width: 110)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(height: 100)
            }
            .frame(width: 120)
            .background(AppColors.secondaryBg.swiftUIColor)
            .cornerRadius(12)
            .shadow(color: AppColors.black.swiftUIColor.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}
#endif
