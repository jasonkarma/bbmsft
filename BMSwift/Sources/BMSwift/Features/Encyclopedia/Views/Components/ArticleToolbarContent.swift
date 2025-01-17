#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleToolbarContent: View {
    @ObservedObject var viewModel: ArticleDetailViewModel
    
    private var isLiked: Bool {
        viewModel.articleDetail?.clientsAction.isLiked == true
    }
    
    private var isKept: Bool {
        viewModel.articleDetail?.clientsAction.isKept == true
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
            }
            .overlay {
                if let message = viewModel.likeMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .offset(y: -25)
                        .transition(.opacity)
                }
            }
            
            // Keep button
            Button {
                Task {
                    await viewModel.keepArticle()
                }
            } label: {
                Image(systemName: isKept ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 20))
                    .foregroundColor(isKept ? .blue : .gray)
            }
            .overlay {
                if let message = viewModel.keepMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .offset(y: -25)
                        .transition(.opacity)
                }
            }
        }
        .frame(height: 44)
        .buttonStyle(.plain)
    }
}
#endif
