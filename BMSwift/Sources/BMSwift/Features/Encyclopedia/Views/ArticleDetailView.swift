#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public struct ArticleDetailView: View {
    @StateObject private var viewModel: ArticleDetailViewModel
    
    public init(viewModel: ArticleDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        contentView
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarContent
                }
            }
            .task {
                await viewModel.loadContent()
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ArticleLoadingView(viewModel: viewModel)
        } else if let error = viewModel.error {
            ArticleErrorView(viewModel: viewModel)
        } else if let article = viewModel.articleDetail {
            articleContent(article)
        } else {
            ArticleEmptyView()
        }
    }
    
    @ViewBuilder
    private var toolbarContent: some View {
        if !viewModel.isLoading, viewModel.error == nil {
            ArticleToolbarContent(viewModel: viewModel)
        }
    }
    
    private func articleContent(_ article: ArticleDetailResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ArticleHeaderView(info: article.info)
                if !article.cnt.isEmpty {
                    ArticleBodyView(article: article)
                }
                if !article.keywords.isEmpty || !article.suggests.isEmpty || !viewModel.comments.isEmpty {
                    ArticleFooterView(
                        article: article,
                        comments: viewModel.comments,
                        viewModel: viewModel
                    )
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
        .refreshable {
            await viewModel.loadContent()
        }
    }
}
#endif
