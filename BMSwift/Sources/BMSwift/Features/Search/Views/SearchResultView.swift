#if canImport(UIKit) && os(iOS)
import SwiftUI

typealias ContentType = KeywordSearchViewModel.ContentType

@available(iOS 13.0, *)
internal struct SearchResultView: View {
    @ObservedObject var viewModel: KeywordSearchViewModel

    @Binding var isPresented: Bool
    
    internal init(viewModel: KeywordSearchViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            // Header
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "chevron.left")
                        .bmForegroundColor(AppColors.primary)
                }
                
                if let hashtag = viewModel.selectedHashtag, let type = viewModel.selectedType {
                    Text("#\(hashtag) - \(ContentType(rawValue: type)?.title ?? "")")
                        .font(.system(size: 16, weight: .medium))
                        .bmForegroundColor(AppColors.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            // Content
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary.swiftUIColor))
                    .scaleEffect(1.5)
                
            case .error(let error):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .bmForegroundColor(AppColors.error)
                    
                    Text(error.localizedDescription)
                        .multilineTextAlignment(.center)
                        .bmForegroundColor(AppColors.error)
                    
                    Button(action: {
                        Task {
                            await viewModel.performSearch()
                        }
                    }) {
                        Text("Retry")
                            .bmForegroundColor(AppColors.primary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AppColors.black.swiftUIColor)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
            case .loaded:
                if viewModel.searchResults.isEmpty && viewModel.canSearch {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .bmForegroundColor(AppColors.primary)
                        
                        Text("No results found")
                            .multilineTextAlignment(.center)
                            .bmForegroundColor(AppColors.primary)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.searchResults, id: \.id) { article in
                                ArticleCardView(article: article, token: viewModel.token)
                                    .background(AppColors.black.swiftUIColor.opacity(0.5))
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .background(AppColors.black.swiftUIColor)
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView(
            viewModel: KeywordSearchViewModel(
                service: EncyclopediaService(client: .shared),
                token: "preview-token",
                encyclopediaViewModel: EncyclopediaViewModel(token: "preview-token")
            ),
            isPresented: .constant(true)
        )
    }
}
#endif
#endif
