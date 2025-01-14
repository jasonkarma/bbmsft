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
        contentView
            .task {
                await viewModel.loadFrontPageContent()
            }
    }
    
    private var contentView: some View {
        ZStack {
            AppColors.primaryBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        if !viewModel.hotArticles.isEmpty {
                            articleSection(title: "热门文章", articles: viewModel.hotArticles)
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
    
    private func articleSection(title: String, articles: [ArticlePreview]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(articles, id: \.id) { article in
                        ArticleCardView(article: article)
                            .task {
                                await viewModel.loadArticle(id: article.id)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var voiceCommandArea: some View {
        HStack {
            Image(systemName: "mic.fill")
                .foregroundColor(.white)
                .font(.title2)
            
            Text("按住说话")
                .foregroundColor(.white)
                .font(.body)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var smartDeviceStats: some View {
        HStack {
            Text("智能设备")
                .foregroundColor(.white)
                .font(.body)
            
            Spacer()
            
            Text("0")
                .foregroundColor(.white)
                .font(.body)
        }
        .padding()
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
        case 3: return "设置"
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
