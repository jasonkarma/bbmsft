#if canImport(UIKit) && os(iOS)
import SwiftUI
import UIKit

// MARK: - Results View

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
                            value: min(face.attributes.skinstatus.health, 10),
                            icon: "heart.fill",
                            color: .green,
                            showAsRating: true
                        )
                        
                        SkinStatusRowView(
                            title: "斑點",
                            value: min(face.attributes.skinstatus.stain, 10),
                            icon: "circle.fill",
                            color: .brown,
                            showAsRating: true
                        )
                        
                        SkinStatusRowView(
                            title: "痘痘",
                            value: min(face.attributes.skinstatus.acne, 10),
                            icon: "exclamationmark.circle.fill",
                            color: .red,
                            showAsRating: true
                        )
                        
                        SkinStatusRowView(
                            title: "黑眼圈",
                            value: min(face.attributes.skinstatus.darkCircle, 10),
                            icon: "eye.fill",
                            color: .purple,
                            showAsRating: true
                        )
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
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
                        
                        DetailRowView(
                            title: "臉部品質",
                            value: "\(Int(face.attributes.facequality.value))%"
                        )
                    }
                    .padding()
                    .background(AppColors.primaryBg.swiftUIColor)
                    .cornerRadius(12)
                    
                    // Emotions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("情緒分析")
                            .font(.headline)
                        
                        EmotionBarView(
                            title: "開心",
                            value: face.attributes.emotion.happiness,
                            color: .yellow
                        )
                        
                        EmotionBarView(
                            title: "中性",
                            value: face.attributes.emotion.neutral,
                            color: .gray
                        )
                        
                        EmotionBarView(
                            title: "生氣",
                            value: face.attributes.emotion.anger,
                            color: .red
                        )
                        
                        EmotionBarView(
                            title: "傷心",
                            value: face.attributes.emotion.sadness,
                            color: .blue
                        )
                        
                        EmotionBarView(
                            title: "驚訝",
                            value: face.attributes.emotion.surprise,
                            color: .purple
                        )
                    }
                    .padding()
                    .background(AppColors.primaryBg.swiftUIColor)
                    .cornerRadius(12)
                    
                    // Eye Status
                    VStack(alignment: .leading, spacing: 16) {
                        Text("眼睛狀態")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("左眼")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                DetailRowView(
                                    title: "睜開",
                                    value: "\(Int(face.attributes.eyestatus.leftEye.noGlassEyeOpen))%"
                                )
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("右眼")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                DetailRowView(
                                    title: "睜開",
                                    value: "\(Int(face.attributes.eyestatus.rightEye.noGlassEyeOpen))%"
                                )
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.primaryBg.swiftUIColor)
                    .cornerRadius(12)
                } else {
                    Text("No face detected")
                        .foregroundColor(.secondary)
                        .padding()
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
private struct SkinStatusRowView: View {
    let title: String
    let value: Float
    let icon: String
    let color: Color
    var showAsRating: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            if showAsRating {
                Text(String(format: "%.1f/10", value))
                    .foregroundColor(.secondary)
            } else {
                Text(String(format: "%.1f%%", value))
                    .foregroundColor(.secondary)
            }
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

@available(iOS 16.0, *)
struct EmotionBarView: View {
    let title: String
    let value: Float
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value))%")
                    .font(.headline)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                        .frame(width: geometry.size.width, height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value) / 100, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - View Model

@MainActor
final class ResultsViewModel: ObservableObject {
    @Published var response: SkinAnalysisModels.Response?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let service: SkinAnalysisServiceProtocol
    private let imageData: Data
    
    init(service: SkinAnalysisServiceProtocol = SkinAnalysisServiceImpl(), imageData: Data) {
        self.service = service
        self.imageData = imageData
    }
    
    func fetchResult() {
        isLoading = true
        error = nil
        
        Task {
            do {
                print("DEBUG: Starting face analysis")
                guard let image = UIImage(data: imageData) else {
                    throw SkinAnalysisError.invalidImage
                }
                let response = try await service.analyzeSkin(image: image)
                
                await MainActor.run {
                    self.response = response
                    self.isLoading = false
                }
            } catch {
                print("DEBUG: Face analysis error: \(error)")
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Results Container

@MainActor
struct ResultsContainerView: View {
    @StateObject private var viewModel: ResultsViewModel
    
    init(imageData: Data) {
        _viewModel = StateObject(wrappedValue: ResultsViewModel(imageData: imageData))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else if let response = viewModel.response {
                ResultsView(isPresented: .constant(true), result: response)
            } else {
                Text("No data available.")
            }
        }
        .onAppear {
            viewModel.fetchResult()
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

struct ResultsContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsContainerView(imageData: Data())
    }
}
#endif

#endif
