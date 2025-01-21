#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct AnalysisLoadingView: View {
    // MARK: - Properties
    @State private var angle: Double = 0
    
    public init() {}
    
    // MARK: - Body
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .rotationEffect(.degrees(angle))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        angle = 360
                    }
                }
            
            Text("分析中...")
                .font(.headline)
                .bmForegroundColor(AppColors.primaryText)
            
            Text("請稍候片刻")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .background(AppColors.primaryBg.swiftUIColor)
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct AnalysisLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisLoadingView()
    }
}
#endif
#endif
