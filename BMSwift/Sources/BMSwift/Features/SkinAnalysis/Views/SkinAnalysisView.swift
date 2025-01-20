#if canImport(SwiftUI) && os(iOS)
import SwiftUI


@available(iOS 13.0, *)
public struct SkinAnalysisView: View {
    @StateObject private var viewModel = SkinAnalysisViewModel()
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                AppColors.primaryBg.swiftUIColor
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    if viewModel.isAnalyzing {
                        analysisLoadingView
                    } else if let results = viewModel.results {
                        ResultsView(results: results)
                    } else {
                        CameraScannerView(onCapture: { image in
                            Task {
                                await viewModel.analyze(image: image)
                            }
                        })
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .bmForegroundColor(AppColors.primary)
                    }
                }
                
                if !viewModel.isAnalyzing && viewModel.results == nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.toggleFlash) {
                            Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .bmForegroundColor(AppColors.primary)
                        }
                    }
                }
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("分析失敗"),
                    message: Text(viewModel.error?.localizedDescription ?? "未知錯誤"),
                    dismissButton: .default(Text("確定"))
                )
            }
        }
    }
    
    private var analysisLoadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("分析中...")
                .font(.headline)
                .bmForegroundColor(AppColors.primaryText)
        }
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct SkinAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        SkinAnalysisView(isPresented: .constant(true))
    }
}
#endif

@available(iOS 13.0, *)
public struct RequestCameraPermissionView: View {
    let onRequest: () -> Void
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            
            Text("需要相機權限")
                .font(.headline)
            
            Text("請允許使用相機來進行膚質分析")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onRequest) {
                Text("授予權限")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 44)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
            }
        }
    }
}

@available(iOS 13.0, *)
public struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            Text("發生錯誤")
                .font(.title)
                .foregroundStyle(.primary)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onRetry) {
                Text("重試")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 44)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
            }
        }
        .padding()
    }
}

#endif
