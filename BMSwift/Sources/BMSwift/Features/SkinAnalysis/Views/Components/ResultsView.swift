#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ResultsView: View {
    private let results: AnalysisResults
    
    public init(results: AnalysisResults) {
        self.results = results
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                scoreSection
                detailsSection
                recommendationsSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .bmBackground(AppColors.primaryBg)
    }
    
    private var scoreSection: some View {
        VStack(spacing: 16) {
            Text("分析結果")
                .font(.title2)
                .bmForegroundColor(AppColors.primaryText)
            
            ZStack {
                Circle()
                    .bmStroke(AppColors.primary.opacity(0.3), lineWidth: 8)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: CGFloat(results.score) / 100)
                    .bmStroke(AppColors.primary, lineWidth: 8)
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(results.score)")
                        .font(.system(size: 48, weight: .bold))
                        .bmForegroundColor(AppColors.primary)
                    Text("分")
                        .font(.subheadline)
                        .bmForegroundColor(AppColors.secondaryText)
                }
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("詳細分析")
                .font(.headline)
                .bmForegroundColor(AppColors.primaryText)
            
            ForEach(results.details, id: \.category) { detail in
                HStack {
                    Text(detail.category)
                        .font(.subheadline)
                        .bmForegroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Text("\(detail.score)分")
                        .font(.subheadline)
                        .bmForegroundColor(AppColors.primary)
                }
                .padding()
                .bmBackground(AppColors.secondaryBg)
                .cornerRadius(8)
            }
        }
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("建議")
                .font(.headline)
                .bmForegroundColor(AppColors.primaryText)
            
            ForEach(results.recommendations, id: \.self) { recommendation in
                HStack(spacing: 12) {
                    Circle()
                        .bmFill(AppColors.primary)
                        .frame(width: 6, height: 6)
                    
                    Text(recommendation)
                        .font(.body)
                        .bmForegroundColor(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(
            results: AnalysisResults(
                score: 85,
                details: [
                    .init(category: "膚質", score: 90),
                    .init(category: "色調", score: 80),
                    .init(category: "彈性", score: 85)
                ],
                recommendations: [
                    "保持良好的防曬習慣",
                    "增加保濕產品的使用",
                    "注意清潔步驟的完整性"
                ]
            )
        )
    }
}
#endif
#endif
