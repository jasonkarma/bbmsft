#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import BMSwift

public struct EncyclopediaView: View {
    @StateObject private var viewModel = EncyclopediaViewModel()
    @State private var selectedTab = 0
    @Binding var isPresented: Bool
    private let token: String
    
    public init(isPresented: Binding<Bool>, token: String) {
        self._isPresented = isPresented
        self.token = token
    }
    
    public var body: some View {
        contentView
            .task {
                await viewModel.loadFrontPageContent(token: token)
            }
    }
    
    private var contentView: some View {
        VStack(spacing: 8) {
            mainContentArea
            bottomNavigation
        }
    }
    
    private var mainContentArea: some View {
        ZStack {
            AppColors.primaryBg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    voiceCommandArea
                    smartDeviceStats
                    if !viewModel.hotArticles.isEmpty {
                        articleSection(title: "熱門文章", articles: viewModel.hotArticles)
                    }
                    if !viewModel.latestArticles.isEmpty {
                        articleSection(title: "最新文章", articles: viewModel.latestArticles)
                    }
                }
                .padding(.vertical)
            }
        }
    }
    
    private var voiceCommandArea: some View {
        HStack {
            Text("取得美容百科文章資料 10 篇")
                .foregroundColor(.white)
            
            Spacer()
            
            voiceCommandButton
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
    
    private var voiceCommandButton: some View {
        Button(action: {
            // Voice command functionality will be implemented later
        }) {
            Image(systemName: "mic.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Circle().stroke(Color.white, lineWidth: 2))
        }
    }
    
    private var smartDeviceStats: some View {
        VStack(spacing: 8) {
            // Bar chart container
            VStack(alignment: .leading, spacing: 0) {
                // Chart header
                HStack {
                    Text("TEST BAR VIEW")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Chart content
                // Will be implemented later
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 200)
                    .padding(.top, 8)
            }
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private func articleSection(title: String, articles: [ArticlePreview]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(articles) { article in
                    ArticleCardView(article: article) {
                        // Handle article tap
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 24))
                        Text(tabTitle(for: index))
                            .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "AI功能"
        case 1: return "文章"
        case 2: return "收藏"
        case 3: return "設定"
        default: return ""
        }
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "wand.and.stars"
        case 1: return "doc.text"
        case 2: return "heart"
        case 3: return "gearshape"
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
