#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleToolbarContent: View {
    @ObservedObject var viewModel: ArticleDetailViewModel
    
    private var isLiked: Bool {
        viewModel.articleDetail?.clientsAction.like == true
    }
    
    private var isKept: Bool {
        viewModel.articleDetail?.clientsAction.keep == true
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Like button
            Button {
                Task {
                    await viewModel.likeArticle()
                }
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(isLiked ? .red : .gray)
                    .scaleEffect(isLiked ? 1.1 : 1.0)
            }
            .animation(.spring(response: 0.3), value: isLiked)
            
            // Keep button
            Button {
                Task {
                    await viewModel.keepArticle()
                }
            } label: {
                Image(systemName: isKept ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 20))
                    .foregroundColor(isKept ? .blue : .gray)
                    .scaleEffect(isKept ? 1.1 : 1.0)
            }
            .animation(.spring(response: 0.3), value: isKept)
        }
        .frame(height: 44)
        .buttonStyle(.plain)
    }
}
#endif
