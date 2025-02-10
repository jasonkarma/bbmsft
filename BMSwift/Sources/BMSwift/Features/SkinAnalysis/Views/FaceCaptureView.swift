// #if canImport(UIKit) && os(iOS)
// import SwiftUI
// import AVFoundation

// @available(iOS 16.0, *)
// public struct FaceCaptureView: View {
//     @Binding var isPresented: Bool
//     @Binding var analysisResult: SkinAnalysisModels.Response?
//     @Binding var analysisError: SkinAnalysisError?
//     @StateObject private var viewModel = CameraScannerViewModel()
    
//     public init(
//         isPresented: Binding<Bool>,
//         analysisResult: Binding<SkinAnalysisModels.Response?>,
//         analysisError: Binding<SkinAnalysisError?>
//     ) {
//         self._isPresented = isPresented
//         self._analysisResult = analysisResult
//         self._analysisError = analysisError
//     }
    
//     public var body: some View {
//         ZStack {
//             // Background color
//             AppColors.primaryBg.swiftUIColor
//                 .ignoresSafeArea()
            
//             // Camera preview
//             if let previewLayer = viewModel.previewLayer {
//                 CameraPreviewView(previewLayer: previewLayer)
//                     .ignoresSafeArea()
//             }
            
//             // Face outline guide
//             VStack {
//                 Spacer()
//                 ZStack {
//                     // Outer border
//                     RoundedRectangle(cornerRadius: 16)
//                         .stroke(AppColors.primary.swiftUIColor, lineWidth: 2)
//                         .frame(width: 280, height: 280)
                    
//                     // Face outline
//                     Image(systemName: "person.fill")
//                         .resizable()
//                         .aspectRatio(contentMode: .fit)
//                         .frame(width: 160, height: 160)
//                         .foregroundColor(AppColors.primary.swiftUIColor.opacity(0.3))
//                 }
//                 .padding(.bottom, 100)
                
//                 // Capture button
//                 Button(action: {
//                     Task {
//                         await viewModel.capturePhoto()
//                     }
//                 }) {
//                     ZStack {
//                         Circle()
//                             .stroke(AppColors.primary.swiftUIColor, lineWidth: 3)
//                             .frame(width: 80, height: 80)
                        
//                         Circle()
//                             .fill(AppColors.primary.swiftUIColor.opacity(0.2))
//                             .frame(width: 70, height: 70)
                        
//                         Text("拍照")
//                             .font(.system(size: 18, weight: .medium))
//                             .foregroundColor(AppColors.primary.swiftUIColor)
//                     }
//                 }
//                 .padding(.bottom, 40)
//             }
            
//             // Top overlay with guide text
//             VStack {
//                 Text("請將臉部對準框內")
//                     .font(.system(size: 20, weight: .medium))
//                     .foregroundColor(AppColors.primary.swiftUIColor)
//                     .padding(.top, 20)
//                 Spacer()
//             }
//         }
//         .onAppear {
//             Task {
//                 await viewModel.checkCameraPermission()
//                 await viewModel.setupCamera()
//             }
//         }
//         .onChange(of: viewModel.capturedImage) { image in
//             if let image = image {
//                 Task {
//                     await viewModel.analyzeSkin(image: image)
//                 }
//             }
//         }
//         .onChange(of: viewModel.analysisResult) { result in
//             if let result = result {
//                 analysisResult = result
//                 isPresented = false
//             }
//         }
//         .onChange(of: viewModel.error) { error in
//             if let error = error {
//                 analysisError = error
//                 isPresented = false
//             }
//         }
//     }
// }

// private struct CameraPreviewView: UIViewRepresentable {
//     let previewLayer: AVCaptureVideoPreviewLayer
    
//     func makeUIView(context: Context) -> UIView {
//         let view = UIView(frame: .zero)
//         previewLayer.videoGravity = .resizeAspectFill
//         view.layer.addSublayer(previewLayer)
//         return view
//     }
    
//     func updateUIView(_ uiView: UIView, context: Context) {
//         previewLayer.frame = uiView.bounds
//     }
// }

// #if DEBUG
// struct FaceCaptureView_Previews: PreviewProvider {
//     static var previews: some View {
//         FaceCaptureView(
//             isPresented: .constant(true),
//             analysisResult: .constant(nil),
//             analysisError: .constant(nil)
//         )
//     }
// }
// #endif
// #endif
