#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ArticleLoadingView: View {
    @State private var isAnimating = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryText.swiftUIColor))
            Text("載入中...")
                .font(.subheadline)
                .bmForegroundColor(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bmBackground(AppColors.primaryBg)
    }
}

@available(iOS 13.0, *)
public struct ArticleEmptyView: View {
    let message: String
    let systemImage: String
    
    public init(
        message: String = "No Content Available",
        systemImage: String = "doc.text"
    ) {
        self.message = message
        self.systemImage = systemImage
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .bmForegroundColor(AppColors.primaryText)
            
            Text(message)
                .font(.headline)
                .bmForegroundColor(AppColors.primary)
            
            Text("Check back later for updates")
                .font(.subheadline)
                .bmForegroundColor(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bmBackground(AppColors.primaryBg.opacity(0.1))
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct ArticleLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ArticleLoadingView()
            ArticleEmptyView()
        }
    }
}
#endif
#endif
