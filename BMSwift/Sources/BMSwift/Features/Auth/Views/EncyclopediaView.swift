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
        ZStack {
            AppColors.primaryBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        if !viewModel.hotArticles.isEmpty {
                            articleSection(title: "熱門文章", articles: viewModel.hotArticles)
                        }
                        if !viewModel.latestArticles.isEmpty {
                            articleSection(title: "最新文章", articles: viewModel.latestArticles)
                        }
                    }
                    .padding(.vertical)
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
    
    private var voiceCommandArea: some View {
        HStack {
            Text("取得美容百科文章資料 10 篇")
                .foregroundColor(.white)
            
            Spacer()
            
            voiceCommandButton
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
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
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.blue)
                Text("心率")
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "figure.walk")
                    .foregroundColor(.green)
                Text("步數")
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                Text("消耗")
                    .foregroundColor(.white)
            }
            .font(.system(size: 12))
            .padding(.horizontal)

            HStack(spacing: 0) {
                // Y-axis values
                VStack(alignment: .trailing, spacing: 0) {
                    Text("200")
                        .foregroundColor(.white)
                        .font(.system(size: 10))
                    Spacer()
                    Text("100")
                        .foregroundColor(.white)
                        .font(.system(size: 10))
                    Spacer()
                    Text("0")
                        .foregroundColor(.white)
                        .font(.system(size: 10))
                }
                .frame(width: 25)
                .padding(.trailing, 4)
                
                // Bars
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(0..<5) { index in
                        VStack(spacing: 2) {
                            Rectangle()
                                .fill(Color.yellow.opacity(0.8))
                                .frame(width: 16, height: CGFloat.random(in: 15...50))
                            
                            Text("\(index * 6)")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                        }
                        if index < 4 {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 60)
        }
        .padding(.vertical, 6)
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
                    .padding(.horizontal)
                }
            }
        }
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
        .padding(.vertical, 4)
        .background(Color.black)
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
