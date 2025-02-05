#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 16.0, *)
public struct AnalysisLoadingView: View {
    @State private var isAnimating = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppColors.primaryBg.swiftUIColor
                .opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(AppColors.primary.swiftUIColor)
                
                Text("正在分析中...")
                    .font(.headline)
                    .bmForegroundColor(AppColors.primaryText)
                
                Text("請稍候片刻")
                    .font(.subheadline)
                    .bmForegroundColor(AppColors.secondaryText)
            }
            .padding(32)
            .bmBackground(AppColors.secondaryBg)
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct AnalysisLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisLoadingView()
    }
}
#endif
#endif
