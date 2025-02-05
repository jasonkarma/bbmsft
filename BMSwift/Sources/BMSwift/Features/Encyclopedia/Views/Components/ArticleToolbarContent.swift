#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ArticleToolbarContent: View {
    @ObservedObject var viewModel: ArticleDetailViewModel
    
    public init(viewModel: ArticleDetailViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            if case .loaded(let article) = viewModel.state {
                // Like button
                Button {
                    Task {
                        await viewModel.likeArticle()
                    }
                } label: {
                    Image(systemName: article.clientsAction.isLiked ? "heart.fill" : "heart")
                        .bmForegroundColor(AppColors.primary)
                        .font(.title2)
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
                    Image(systemName: article.clientsAction.isKept ? "bookmark.fill" : "bookmark")
                        .bmForegroundColor(AppColors.primary)
                        .font(.title2)
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
        }
        .frame(height: 44)
        .buttonStyle(.plain)
    }
}
#endif
