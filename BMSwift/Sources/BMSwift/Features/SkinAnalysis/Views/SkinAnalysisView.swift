#if canImport(UIKit) && os(iOS)
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

@available(iOS 16.0, *)
public struct SkinAnalysisView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = SkinAnalysisViewModel()
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
            ZStack {
                AppColors.primaryBg.swiftUIColor
                    .ignoresSafeArea()
                
                VStack {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    }
                    
                    if viewModel.isAnalyzing {
                        ProgressView("分析中...")
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryText.swiftUIColor))
                            .scaleEffect(1.5)
                    } else if let result = viewModel.analysisResult {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Overall Score
                                HStack {
                                    Text("整體評分")
                                        .font(.headline)
                                        .bmForegroundColor(AppColors.primaryText)
                                    Spacer()
                                    Text(String(format: "%.1f", result.overallScore))
                                        .font(.title)
                                        .bmForegroundColor(AppColors.primary)
                                }
                                .padding()
                                .background(AppColors.secondaryBg.swiftUIColor)
                                .cornerRadius(8)
                                
                                // Detailed Scores
                                ForEach(result.detailedScores) { score in
                                    HStack {
                                        Text(score.category)
                                            .font(.subheadline)
                                            .bmForegroundColor(AppColors.primaryText)
                                        Spacer()
                                        Text(String(format: "%.1f", score.score))
                                            .font(.headline)
                                            .bmForegroundColor(AppColors.primary)
                                    }
                                    .padding()
                                    .background(AppColors.secondaryBg.swiftUIColor)
                                    .cornerRadius(8)
                                }
                                
                                // Recommendations
                                if !result.recommendations.isEmpty {
                                    Text("建議")
                                        .font(.headline)
                                        .bmForegroundColor(AppColors.primaryText)
                                        .padding(.top)
                                    
                                    ForEach(result.recommendations, id: \.self) { recommendation in
                                        Text("• " + recommendation)
                                            .font(.subheadline)
                                            .bmForegroundColor(AppColors.primaryText)
                                            .padding(.vertical, 4)
                                    }
                                }
                            }
                            .padding()
                        }
                    } else {
                        PhotosPicker(
                            selection: $viewModel.selectedPhotoItem,
                            matching: .images
                        ) {
                            VStack(spacing: 16) {
                                Image(systemName: "camera")
                                    .font(.system(size: 48))
                                    .bmForegroundColor(AppColors.primary)
                                Text("選擇照片")
                                    .font(.headline)
                                    .bmForegroundColor(AppColors.primaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 48)
                            .background(AppColors.secondaryBg.swiftUIColor)
                            .cornerRadius(12)
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("肌膚分析")
            .navigationBarTitleDisplayMode(.inline)
            .alert("錯誤", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.clearError() } }
            )) {
                Button("確定", role: .cancel) {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
            .toolbar {
                if viewModel.selectedImage != nil {
                    Button("重新選擇") {
                        viewModel.reset()
                    }
                }
                Button("關閉") {
                    isPresented = false
                }
            }
            .onChange(of: viewModel.selectedPhotoItem) { photoItem in
                guard let photoItem else { return }
                Task {
                    if let data = try? await photoItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.selectedImage = image
                        await viewModel.analyzeSkin(image: image)
                    }
                }
            }
            .navigationTitle("肌膚分析")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct SkinAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        SkinAnalysisView(isPresented: .constant(true))
            .environmentObject(SkinAnalysisViewModel.preview())
    }
}
#endif
#endif
