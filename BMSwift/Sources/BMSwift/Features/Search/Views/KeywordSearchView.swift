#if canImport(UIKit)
import SwiftUI

@available(iOS 13.0, *)
public extension BMSearchV2.Search {
    struct KeywordSearchView: View {
        @StateObject private var viewModel: KeywordSearchViewModel
        @Binding public var isPresented: Bool
        @State private var searchText: String = ""
        
        public init(token: String, service: SearchServiceProtocol = SearchService(client: .shared), isPresented: Binding<Bool>) {
            self._viewModel = StateObject(wrappedValue: KeywordSearchViewModel(
                service: service,
                token: token
            ))
            self._isPresented = isPresented
        }
        
        public var body: some View {
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Text("搜尋")
                        .font(.system(size: 16, weight: .medium))
                        .bmForegroundColor(AppColors.primary)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .bmForegroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(AppColors.black.swiftUIColor)
                
                // Search bar
                HStack {
                    TextField("輸入搜尋內容", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .bmForegroundColor(AppColors.primaryText)
                    
                    Button(action: {
                        guard !searchText.isEmpty else { return }
                        viewModel.performTextSearch(searchText)
                    }) {
                        Text("搜尋")
                            .bmForegroundColor(AppColors.primaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppColors.primary.swiftUIColor)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Divider()
                    .background(AppColors.gray.swiftUIColor)
                
                // Results View
                ResultsView(viewModel: viewModel, searchText: searchText)
            }
            .background(AppColors.black.swiftUIColor)
            .cornerRadius(12)
        }
    }
    
    private struct ResultsView: View {
        @ObservedObject var viewModel: KeywordSearchViewModel
        let searchText: String
        
        var body: some View {
            switch viewModel.state {
            case .loading:
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryText.swiftUIColor))
                        .scaleEffect(1.5)
                }
                .frame(height: 200)
                
            case .error(let error):
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .padding()
                
            case .loaded:
                VStack(spacing: 16) {
                    if !viewModel.searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.searchResults) { article in
                                    ArticleCardView(
                                        article: article,
                                        token: viewModel.token,
                                        onTap: {
                                            // TODO: Navigate to article detail
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                    } else if !searchText.isEmpty {
                        Text("No results found")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 13.0, *)
public struct KeywordSearchView_Previews: PreviewProvider {
    public static var previews: some View {
        KeywordSearchView(
            token: "preview-token",
            service: BMSearchV2.Search.Service(client: .shared),
            isPresented: .constant(true)
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif
#endif
