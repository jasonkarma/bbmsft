#if canImport(UIKit) && os(iOS)
import SwiftUI

@available(iOS 16.0, *)
public struct ResultsView: View {
    let result: SkinAnalysisResponse
    let onDismiss: () -> Void
    
    public init(result: SkinAnalysisResponse, onDismiss: @escaping () -> Void) {
        self.result = result
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Overall Score
            VStack(spacing: 8) {
                Text("整體評分")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText.swiftUIColor)
                
                Text(String(format: "%.1f", result.overallScore))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppColors.primary.swiftUIColor)
            }
            
            // Detailed Scores
            VStack(spacing: 16) {
                Text("詳細評分")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText.swiftUIColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(result.detailedScores, id: \.category) { score in
                    HStack {
                        Text(score.category)
                            .font(.subheadline)
                            .foregroundColor(AppColors.primaryText.swiftUIColor)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", score.score))
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundColor(AppColors.primary.swiftUIColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.secondaryBg.swiftUIColor)
                    .cornerRadius(8)
                }
            }
            
            // Recommendations
            if !result.recommendations.isEmpty {
                VStack(spacing: 16) {
                    Text("建議改善")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText.swiftUIColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(result.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.primary.swiftUIColor)
                                .font(.system(size: 20))
                            
                            Text(recommendation)
                                .font(.subheadline)
                                .foregroundColor(AppColors.primaryText.swiftUIColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.secondaryBg.swiftUIColor)
                        .cornerRadius(8)
                    }
                }
            }
            
            Button(action: onDismiss) {
                Text("完成")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.primary.swiftUIColor)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(AppColors.primaryBg.swiftUIColor)
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(
            result: .preview,
            onDismiss: {}
        )
    }
}
#endif
#endif
