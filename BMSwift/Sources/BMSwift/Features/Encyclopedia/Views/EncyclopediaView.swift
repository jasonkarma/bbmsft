#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct EncyclopediaView: View {
    enum Route: Hashable {
        case article(ArticlePreview)
        case skinAnalysis
        case profile
    }
    
    @StateObject private var viewModel: EncyclopediaViewModel
    @State private var selectedTab = 0
    @State private var path = NavigationPath()
    @Binding var isPresented: Bool
    private let token: String
    
    public init(isPresented: Binding<Bool>, token: String) {
        self._isPresented = isPresented
        self.token = token
        self._viewModel = StateObject(wrappedValue: EncyclopediaViewModel(token: token))
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
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
                                                    NavigationLink(value: Route.article(article)) {
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
                                if let frontPageContent = viewModel.frontPageContent {
                                    BannerArticleView(articles: frontPageContent.latestContents) { article in
                                        path.append(Route.article(article))
                                    }
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
                            .fill(AppColors.black.swiftUIColor.opacity(1))
                            .frame(height: geometry.safeAreaInsets.top)
                        Spacer()
                    }
                    .ignoresSafeArea()
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .article(let article):
                    ArticleDetailView(viewModel: ArticleDetailViewModel(articleId: article.id, token: token))
                case .skinAnalysis:
                    SkinAnalysisView(isPresented: $isPresented)
                case .profile:
                    ProfileView(token: token, isPresented: $isPresented)
                }
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
                .font(.system(size: 24))
                .bmForegroundColor(AppColors.primary)
            
            Text("語音指令")
                .font(.headline)
                .bmForegroundColor(AppColors.primaryText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16))
                .bmForegroundColor(AppColors.primaryText)
        }
        .padding()
    }
    
    private var smartDeviceStats: some View {
        HStack {
            Image(systemName: "iphone")
                .font(.system(size: 24))
                .bmForegroundColor(AppColors.primary)
            
            Text("智能設備")
                .font(.headline)
                .bmForegroundColor(AppColors.primaryText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16))
                .bmForegroundColor(AppColors.primaryText)
        }
        .padding()
    }
    
    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                if index == 0 {
                    NavigationLink(value: Route.skinAnalysis) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .bmForegroundColor(selectedTab == index ? AppColors.primary : AppColors.secondaryText)
                            
                            Text("AI檢測")
                                .font(.caption)
                                .bmForegroundColor(selectedTab == index ? AppColors.primary : AppColors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                } else if index == 1 {
                    Button(action: {
                        selectedTab = index
                    }) {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .bmForegroundColor(selectedTab == index ? AppColors.primary : AppColors.secondaryText)
                            
                            Text("搜尋")
                                .font(.caption)
                                .bmForegroundColor(selectedTab == index ? AppColors.primary : AppColors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                } else {
                    NavigationLink(value: Route.profile) {
                        VStack {
                            Image(systemName: "person.fill")
                                .bmForegroundColor(selectedTab == index ? AppColors.primary : AppColors.secondaryText)
                            
                            Text("我的")
                                .font(.caption)
                                .bmForegroundColor(selectedTab == index ? AppColors.primary : AppColors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
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
