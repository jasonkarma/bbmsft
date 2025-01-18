#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ArticleDetailView: View {
    @StateObject var viewModel: ArticleDetailViewModel
    
    public init(viewModel: ArticleDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            switch viewModel.state {
            case .initial, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let error):
                Text(error.localizedDescription)
                    .foregroundColor(.red)
            case .loaded(let article):
                VStack(alignment: .leading, spacing: 16) {
                    ArticleHeaderView(info: article.info)
                    if !article.cnt.isEmpty {
                        ArticleBodyView(article: article)
                    }
                    if !article.keywords.isEmpty || !article.suggests.isEmpty || !viewModel.comments.isEmpty {
                        ArticleFooterView(
                            article: article,
                            token: viewModel.token,
                            comments: viewModel.comments,
                            viewModel: viewModel,
                            onNavigateToArticle: { @MainActor id in
                                await viewModel.loadContent(forArticleId: id)
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .refreshable {
            await viewModel.loadContent()
        }
        .overlay {
            if viewModel.showToast {
                ToastView(message: viewModel.toastMessage, isPresented: $viewModel.showToast)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ArticleToolbarContent(viewModel: viewModel)
            }
        }
        .task {
            if case .initial = viewModel.state {
                await viewModel.loadContent()
            }
        }
    }
}
#endif
