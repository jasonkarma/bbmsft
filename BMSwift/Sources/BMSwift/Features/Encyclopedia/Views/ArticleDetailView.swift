#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ArticleDetailView: View {
    @StateObject var viewModel: ArticleDetailViewModel
    @State private var scrollOffset: CGFloat = 0
    
    public init(viewModel: ArticleDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)
            
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
                                // Reset scroll position
                                withAnimation {
                                    scrollOffset = 0
                                }
                                return await viewModel.loadContent(forArticleId: id)
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
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
        .onChange(of: viewModel.state) { _ in
            withAnimation {
                scrollOffset = 0
            }
        }
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
#endif
