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
                if let face = result.faces.first {
                    // Beauty Scores
                    VStack(alignment: .leading, spacing: 8) {
                        Text("美顏評分")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(Int(face.attributes.beauty.femaleScore))")
                                    .font(.largeTitle)
                                    .bold()
                                Text("女性評分")
                                    .font(.subheadline)
                            }
                            
                            VStack {
                                Text("\(Int(face.attributes.beauty.maleScore))")
                                    .font(.largeTitle)
                                    .bold()
                                Text("男性評分")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.primaryBg.swiftUIColor)
                    .cornerRadius(12)
                    
                    // Skin Analysis
                    VStack(alignment: .leading, spacing: 16) {
                        Text("膚質分析")
                            .font(.headline)
                        
                        SkinStatusRowView(
                            title: "健康度",
                            value: face.attributes.skinstatus.health,
                            icon: "heart.fill",
                            color: .green
                        )
                        
                        SkinStatusRowView(
                            title: "色斑",
                            value: face.attributes.skinstatus.stain,
                            icon: "circle.fill",
                            color: .brown
                        )
                        
                        SkinStatusRowView(
                            title: "痘痘",
                            value: face.attributes.skinstatus.acne,
                            icon: "dot.circle.fill",
                            color: .red
                        )
                        
                        SkinStatusRowView(
                            title: "黑眼圈",
                            value: face.attributes.skinstatus.darkCircle,
                            icon: "eye.fill",
                            color: .purple
                        )
                    }
                    .padding()
                    .background(AppColors.primaryBg.swiftUIColor)
                    .cornerRadius(12)
                    
                    // Face Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("面部特徵")
                            .font(.headline)
                        
                        DetailRowView(
                            title: "年齡",
                            value: "\(face.attributes.age.value)歲"
                        )
                        
                        DetailRowView(
                            title: "性別",
                            value: face.attributes.gender.value == "Male" ? "男性" : "女性"
                        )
                        
                        DetailRowView(
                            title: "眼鏡",
                            value: {
                                switch face.attributes.glass.value {
                                case "None": return "無"
                                case "Dark": return "墨鏡"
                                case "Normal": return "普通眼鏡"
                                default: return face.attributes.glass.value
                                }
                            }()
                        )
                        
                        DetailRowView(
                            title: "微笑程度",
                            value: "\(Int(face.attributes.smile.value))%"
                        )
                    }
                    .padding()
                    .background(AppColors.primaryBg.swiftUIColor)
                    .cornerRadius(12)
                }
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
struct SkinStatusRowView: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value))%")
                    .font(.headline)
            }
            
            ProgressView(value: value, total: 100)
                .tint(color)
        }
    }
}

@available(iOS 16.0, *)
struct DetailRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ResultsView(isPresented: .constant(true), result: .preview)
        }
    }
}
#endif
#endif
