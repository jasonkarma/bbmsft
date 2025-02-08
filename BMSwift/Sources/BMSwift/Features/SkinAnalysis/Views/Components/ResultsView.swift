#if canImport(UIKit) && os(iOS)
import SwiftUI

@available(iOS 16.0, *)
public struct ResultsView: View {
    @Binding var isPresented: Bool
    let result: SkinAnalysisModels.Response
    
    public init(isPresented: Binding<Bool>, result: SkinAnalysisModels.Response) {
        self._isPresented = isPresented
        self.result = result
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Overall Score
                VStack(alignment: .leading, spacing: 8) {
                    Text("整體評分")
                        .font(.headline)
                    
                    Text("\(result.result.overallImpression.overallScore)")
                        .font(.largeTitle)
                        .bold()
                    
                    Text(result.result.overallImpression.mood)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.secondaryBg.swiftUIColor)
                .cornerRadius(12)
                
                // Photo Analysis
                VStack(alignment: .leading, spacing: 16) {
                    Text("照片分析")
                        .font(.headline)
                    
                    PhotoAnalysisRowView(
                        title: "構圖",
                        score: result.result.photoAnalysis.composition.compositionScore,
                        description: result.result.photoAnalysis.composition.description,
                        elements: result.result.photoAnalysis.composition.notableElements
                    )
                    
                    PhotoAnalysisRowView(
                        title: "光線",
                        score: result.result.photoAnalysis.lighting.lightingScore,
                        description: result.result.photoAnalysis.lighting.description,
                        elements: result.result.photoAnalysis.lighting.notableElements
                    )
                    
                    PhotoAnalysisRowView(
                        title: "色彩",
                        score: result.result.photoAnalysis.color.colorScore,
                        description: result.result.photoAnalysis.color.palette,
                        elements: result.result.photoAnalysis.color.notableElements
                    )
                    
                    TechnicalQualityView(quality: result.result.photoAnalysis.technicalQuality)
                }
                .padding()
                .background(AppColors.secondaryBg.swiftUIColor)
                .cornerRadius(12)
                
                // Facial Features
                VStack(alignment: .leading, spacing: 16) {
                    Text("面部特徵分析")
                        .font(.headline)
                    
                    FeatureDetailView(title: "整體結構", detail: result.result.photoAnalysis.facialFeatures.overallStructure)
                    FeatureDetailView(title: "膚質", detail: result.result.photoAnalysis.facialFeatures.skinQuality)
                    FeatureDetailView(title: "眼部", detail: result.result.photoAnalysis.facialFeatures.eyeArea)
                    FeatureDetailView(title: "嘴部", detail: result.result.photoAnalysis.facialFeatures.mouthArea)
                    FeatureDetailView(title: "鼻部", detail: result.result.photoAnalysis.facialFeatures.noseArea)
                    FeatureDetailView(title: "臉頰", detail: result.result.photoAnalysis.facialFeatures.cheekArea)
                    FeatureDetailView(title: "下顎", detail: result.result.photoAnalysis.facialFeatures.jawArea)
                }
                .padding()
                .background(AppColors.secondaryBg.swiftUIColor)
                .cornerRadius(12)
                
                // Recommendations
                VStack(alignment: .leading, spacing: 16) {
                    Text("建議")
                        .font(.headline)
                    
                    ForEach(result.result.overallImpression.suggestions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb")
                                .foregroundColor(.yellow)
                            Text(suggestion)
                        }
                    }
                    
                    if !result.result.overallImpression.uniqueElements.isEmpty {
                        Text("特點")
                            .font(.subheadline)
                            .padding(.top, 8)
                        
                        ForEach(result.result.overallImpression.uniqueElements, id: \.self) { element in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(element)
                            }
                        }
                    }
                }
                .padding()
                .background(AppColors.secondaryBg.swiftUIColor)
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("分析結果")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    isPresented = false
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct PhotoAnalysisRowView: View {
    let title: String
    let score: Int
    let description: String
    let elements: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(score)")
                    .font(.headline)
            }
            
            Text(description)
            
            if !elements.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(elements, id: \.self) { element in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(element)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct TechnicalQualityView: View {
    let quality: SkinAnalysisModels.TechnicalQuality
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("技術品質")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(quality.qualityScore)")
                    .font(.headline)
            }
            
            Text("清晰度: \(quality.sharpness)")
            Text("曝光: \(quality.exposure)")
            Text("景深: \(quality.depthOfField)")
        }
    }
}

@available(iOS 16.0, *)
struct FeatureDetailView: View {
    let title: String
    let detail: SkinAnalysisModels.FeatureDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                if let score = detail.balanceScore ?? detail.clarityScore ?? detail.harmonyScore ?? 
                              detail.proportionScore ?? detail.contourScore ?? detail.definitionScore {
                    Text("\(score)")
                        .font(.headline)
                }
            }
            Text(detail.description)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResultsView(
                isPresented: .constant(true),
                result: .preview
            )
        }
    }
}
#endif
#endif
