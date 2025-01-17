#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public struct ArticleToolbarContent: View {
    @ObservedObject var viewModel: ArticleDetailViewModel
    
    public var body: some View {
        HStack(spacing: 16) {
            if case .loaded(let article) = viewModel.state {
                Button(action: {
                    Task {
                        await viewModel.likeArticle()
                    }
                }) {
                    Image(systemName: article.clientsAction.like ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(article.clientsAction.like ? .red : .gray)
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
                
                Button(action: {
                    Task {
                        await viewModel.keepArticle()
                    }
                }) {
                    Image(systemName: article.clientsAction.keep ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(article.clientsAction.keep ? .blue : .gray)
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
