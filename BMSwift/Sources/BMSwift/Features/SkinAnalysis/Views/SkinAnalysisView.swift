#if canImport(UIKit) && os(iOS)
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

/// Main view for skin analysis feature that allows users to analyze their skin condition
/// through photo upload and displays detailed analysis results
@available(iOS 16.0, *)
public struct SkinAnalysisView: View {
    // MARK: - Properties
    @Binding var isPresented: Bool
    @StateObject private var viewModel = SkinAnalysisViewModel()
    @State private var showingImagePicker = false
    @State private var showingCameraCapture = false
    @State private var showingResults = false
    @State private var analysisResult: SkinAnalysisModels.Response?
    @State private var analysisError: SkinAnalysisError?
    
    // MARK: - Initialization
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    // MARK: - Body
    public var body: some View {
        ZStack {
            backgroundLayer
            mainContent
        }
        .navigationTitle("肌膚分析")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { navigationToolbar }
        .alert("錯誤", isPresented: .constant(viewModel.error != nil || analysisError != nil)) {
            Button("確定", role: .cancel) {
                viewModel.clearError()
                analysisError = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            } else if let error = analysisError {
                Text(error.localizedDescription)
            }
        }
        .onChange(of: viewModel.selectedPhotoItem) { _ in
            Task {
                await viewModel.analyzeSkin(image: viewModel.selectedImage)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotosPicker(
                selection: $viewModel.selectedPhotoItem,
                matching: .images
            ) {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 48))
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
        .fullScreenCover(isPresented: $showingCameraCapture) {
            NavigationView {
                FaceCaptureView(
                    isPresented: $showingCameraCapture,
                    analysisResult: $analysisResult,
                    analysisError: $analysisError
                )
            }
        }
        .sheet(isPresented: $showingResults) {
            NavigationView {
                if let result = analysisResult {
                    ResultsView(
                        isPresented: $showingResults,
                        result: result
                    )
                }
            }
        }
        .onChange(of: analysisResult) { result in
            if result != nil {
                showingResults = true
            }
        }
        .onChange(of: viewModel.selectedImage) { image in
            if image != nil {
                Task {
                    await viewModel.analyzeSkin(image: image)
                }
            }
        }
    }
    
    // MARK: - View Components
    private var backgroundLayer: some View {
        AppColors.primaryBg.swiftUIColor.ignoresSafeArea()
    }
    
    private var mainContent: some View {
        VStack(spacing: 24) {
            // Title and description
            VStack(spacing: 8) {
                Text("拍攝或選擇照片")
                    .font(.title2)
                    .bmForegroundColor(AppColors.primaryText)
                
                Text("我們將分析您的肌膚狀況，並提供個性化建議")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .bmForegroundColor(AppColors.secondaryText)
                    .padding(.horizontal)
            }
            
            // Image source buttons
            imageSourceButtons
            
            // Loading indicator
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
            
            Spacer()
        }
        .padding(.top, 48)
    }
    
    private var imageSourceButtons: some View {
        HStack(spacing: 16) {
            Button(action: { showingImagePicker = true }) {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 32))
                    Text("相簿")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(AppColors.secondaryBg.swiftUIColor)
                .cornerRadius(12)
            }
            
            Button(action: { showingCameraCapture = true }) {
                VStack(spacing: 8) {
                    Image(systemName: "camera")
                        .font(.system(size: 32))
                    Text("相機")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(AppColors.secondaryBg.swiftUIColor)
                .cornerRadius(12)
            }
        }
        .bmForegroundColor(AppColors.primaryText)
        .padding(.horizontal)
    }
    
    private var navigationToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("關閉") {
                isPresented = false
            }
            .bmForegroundColor(AppColors.primaryText)
        }
    }
}

// MARK: - Preview Provider
#if DEBUG
@available(iOS 16.0, *)
struct SkinAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SkinAnalysisView(isPresented: .constant(true))
        }
    }
}
#endif
#endif
