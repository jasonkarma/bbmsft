#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import BMNetwork

@available(iOS 13.0, *)
public struct EncyclopediaView: View {
    @StateObject private var viewModel: EncyclopediaViewModel
    @State private var selectedTab = 0
    @Binding var isPresented: Bool
    private let token: String
    
    public init(isPresented: Binding<Bool>, token: String) {
        self._isPresented = isPresented
        self.token = token
        self._viewModel = StateObject(wrappedValue: EncyclopediaViewModel(token: token))
    }
    
    public var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    AppColors.primaryBg.swiftUIColor
                        .ignoresSafeArea()
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryText.swiftUIColor))
                            .scaleEffect(1.5)
                    } else if let error = viewModel.error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .bmForegroundColor(AppColors.warning)
                            
                            Text(error.localizedDescription)
                                .bmForegroundColor(AppColors.primaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                Task {
                                    await viewModel.loadFrontPageContent()
                                }
                            }) {
                                Text("重試")
                                    .bmForegroundColor(AppColors.primaryText)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(AppColors.primary.swiftUIColor)
                                    .cornerRadius(8)
                            }
                        }
                    } else {
                        VStack(spacing: 0) {
                            ScrollView {
                                VStack(spacing: 16) {
                                    if !viewModel.hotArticles.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("熱門文章")
                                                .font(.title3)
                                                .bmForegroundColor(AppColors.primary)
                                                .padding(.horizontal)
                                            
                                            LazyVStack(spacing: 8) {
                                                ForEach(viewModel.hotArticles, id: \.id) { article in
                                                    NavigationLink(value: article) {
                                                        ArticleCardView(article: article, token: token)
                                                            .background(AppColors.black.swiftUIColor.opacity(0.5))
                                                            .cornerRadius(12)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                .padding(.bottom)
                            }
                            
                            VStack(spacing: 0) {
                                if !viewModel.latestArticles.isEmpty {
                                    BannerArticleView(articles: viewModel.latestArticles)
                                }
                                
                                VStack(spacing: 0) {
                                    voiceCommandArea
                                        .background(AppColors.black.swiftUIColor)
                                    
                                    smartDeviceStats
                                        .background(AppColors.black.swiftUIColor)
                                    
                                    bottomNavigation
                                }
                            }
                        }
                    }
                    
                    VStack {
                        Rectangle()
                            .fill(AppColors.black.swiftUIColor.opacity(0.5))
                            .frame(height: geometry.safeAreaInsets.top)
                        Spacer()
                    }
                    .ignoresSafeArea()
                }
            }
            .navigationDestination(for: ArticlePreview.self) { article in
                ArticleDetailView(viewModel: ArticleDetailViewModel(articleId: article.id, token: token))
            }
            .task {
                print("[EncyclopediaView] Loading content with token: \(token.prefix(10))...")
                await viewModel.loadFrontPageContent()
            }
        }
    }
    
    private var voiceCommandArea: some View {
        HStack {
            Image(systemName: "mic.fill")
                .bmForegroundColor(AppColors.primary)
                .font(.title2)
            
            Text("按住說話")
                .bmForegroundColor(AppColors.primary)
                .font(.body)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var smartDeviceStats: some View {
        HStack {
            Text("智能設備")
                .bmForegroundColor(AppColors.primary)
                .font(.body)
            
            Spacer()
            
            Text("已連接")
                .bmForegroundColor(AppColors.success)
                .font(.body)
        }
        .padding()
    }
    
    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack {
                        Image(systemName: index == 0 ? "house.fill" : index == 1 ? "magnifyingglass" : "person.fill")
                            .bmForegroundColor(selectedTab == index ? AppColors.primary : AppColors.secondaryText)
                        
                        Text(index == 0 ? "首頁" : index == 1 ? "搜尋" : "我的")
                            .font(.caption)
                            .bmForegroundColor(selectedTab == index ? AppColors.primary : AppColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(AppColors.black.swiftUIColor)
    }
}

#if DEBUG
struct EncyclopediaView_Previews: PreviewProvider {
    static var previews: some View {
        EncyclopediaView(isPresented: .constant(true), token: "preview_token")
    }
}
#endif
#endif
