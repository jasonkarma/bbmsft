import SwiftUI

public extension BMSearchV2.Search {
    struct SearchView: View {
        @StateObject private var viewModel: SearchViewModel
        @Binding private var isPresented: Bool
        @State private var searchText: String = ""
        
        public init(token: String, isPresented: Binding<Bool>) {
            self._viewModel = StateObject(wrappedValue: SearchViewModel(token: token))
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
                        Task {
                            await viewModel.performSearch(keyword: searchText)
                        }
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
                
                // Keywords Section
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.hotKeywords, id: \.self) { keyword in
                            KeywordTagButton(
                                hashtag: keyword,
                                isSelected: keyword == viewModel.selectedKeyword) {
                                Task {
                                    await viewModel.performSearch(keyword: keyword)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Divider()
                    .background(AppColors.gray.swiftUIColor)
                
                // Search Type Picker
                Picker("Search Type", selection: $viewModel.selectedType) {
                    ForEach(viewModel.searchTypes, id: \.self) { type in
                        Text(type.title)
                            .tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Results or Loading View
                if case .loading = viewModel.state {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryText.swiftUIColor))
                            .scaleEffect(1.5)
                    }
                    .frame(height: 200)
                } else if case .error(let error) = viewModel.state {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .padding()
                } else if !viewModel.searchResults.isEmpty {
                    SearchResultsView(
                        results: viewModel.searchResults,
                        token: viewModel.token
                    )
                } else if !searchText.isEmpty {
                    Text("No results found")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(AppColors.black.swiftUIColor)
            .cornerRadius(12)
        }
    }
}

#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        BMSearchV2.Search.SearchView(
            token: "preview-token",
            isPresented: .constant(true)
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif
