#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ArticlePreviewCardView: View {
        private let article: any ArticleCardModel
        private let token: String
        
        public init(article: any ArticleCardModel, token: String) {
            self.article = article
            self.token = token
        }
        
        public var body: some View {
            NavigationLink(destination: ArticleDetailView(viewModel: ArticleDetailViewModel(articleId: article.id, token: token))) {
                BMSwift.ArticleCardView(
                    article: article,
                    token: token,
                    onTap: {}
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .bmStroke(AppColors.secondaryText.opacity(0.5), lineWidth: 1.5)
                )
                .shadow(radius: 4)
            }
            .buttonStyle(.plain)
        }
    }
#endif
