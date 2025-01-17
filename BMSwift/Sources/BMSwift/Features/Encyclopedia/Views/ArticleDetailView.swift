#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ArticleDetailView: View {
    @StateObject var viewModel: ArticleDetailViewModel
    
    public init(viewModel: ArticleDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                } else if let article = viewModel.articleDetail {
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
            }
            .refreshable {
                await viewModel.loadContent()
            }
            
            if viewModel.showToast {
                ToastView(message: viewModel.toastMessage, isPresented: $viewModel.showToast)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.isLoading, viewModel.error == nil {
                    ArticleToolbarContent(viewModel: viewModel)
                }
            }
        }
        .onAppear {
            if viewModel.articleDetail == nil {
                Task {
                    await viewModel.loadContent()
                }
            }
        }
    }
}
#endif
