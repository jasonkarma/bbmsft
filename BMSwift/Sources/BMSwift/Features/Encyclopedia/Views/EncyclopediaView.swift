#if canImport(SwiftUI) && os(iOS)
import SwiftUI

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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                AppColors.primaryBg
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else if let error = viewModel.error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text(error.localizedDescription)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            Task {
                                await viewModel.loadFrontPageContent()
                            }
                        }) {
                            Text("重試")
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(AppColors.primary)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 16) {
                                if !viewModel.hotArticles.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("热門文章")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .padding(.horizontal)
                                        
                                        LazyVStack(spacing: 8) {
                                            ForEach(viewModel.hotArticles, id: \.id) { article in
                                                ArticleCardView(article: article)
                                                    .background(Color.black.opacity(0.5))
                                                    .cornerRadius(12)
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
                                    .background(Color.black)
                                
                                smartDeviceStats
                                    .background(Color.black)
                                
                                bottomNavigation
                            }
                        }
                    }
                }
                
                // Black overlay for notch area
                VStack {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: geometry.safeAreaInsets.top)
                    Spacer()
                }
                .ignoresSafeArea()
            }
        }
        .task {
            print("[EncyclopediaView] Loading content with token: \(token.prefix(10))...")
            await viewModel.loadFrontPageContent()
        }
    }
    
    private var voiceCommandArea: some View {
        HStack {
            Image(systemName: "mic.fill")
                .foregroundColor(.white)
                .font(.title2)
            
            Text("按住說話")
                .foregroundColor(.white)
                .font(.body)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var smartDeviceStats: some View {
        HStack {
            Text("智能設備")
                .foregroundColor(.white)
                .font(.body)
            
            Spacer()
            
            Text("已連接")
                .foregroundColor(.green)
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
                        Image(systemName: tabIcon(for: index))
                            .font(.title3)
                        Text(tabTitle(for: index))
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == index ? AppColors.primary : .gray)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 5)
        .background(Color.black)
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "text.book.closed.fill"
        case 2: return "person.fill"
        default: return ""
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "首页"
        case 1: return "百科"
        case 2: return "我的"
        default: return ""
        }
    }
}

#if DEBUG
struct EncyclopediaView_Previews: PreviewProvider {
    static var previews: some View {
        EncyclopediaView(isPresented: .constant(true), token: "preview-token")
    }
}
#endif
#endif
