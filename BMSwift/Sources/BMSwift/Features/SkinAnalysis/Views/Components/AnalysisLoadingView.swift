#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct AnalysisLoadingView: View {
    @State private var isAnimating = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppColors.primaryBg.swiftUIColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .bmStroke(AppColors.primary.opacity(0.3), lineWidth: 3)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .bmStroke(AppColors.primary, lineWidth: 3)
                        .frame(width: 100, height: 100)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 1)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
                
                Text("分析中...")
                    .font(.headline)
                    .bmForegroundColor(AppColors.primaryText)
            }
        }
        .onAppear {
            isAnimating = true
        }
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
