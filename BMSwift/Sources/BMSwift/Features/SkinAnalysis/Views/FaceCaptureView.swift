import SwiftUI
import AVFoundation

@available(iOS 16.0, *)
public struct FaceCaptureView: View {
    @StateObject private var viewModel = FaceCaptureViewModel()
    @Binding var isPresented: Bool
    @Binding var analysisResult: SkinAnalysisModels.Response?
    @Binding var analysisError: BMSwift.SkinAnalysisError?
    
    public init(isPresented: Binding<Bool>, analysisResult: Binding<SkinAnalysisModels.Response?>, analysisError: Binding<BMSwift.SkinAnalysisError?>) {
        self._isPresented = isPresented
        self._analysisResult = analysisResult
        self._analysisError = analysisError
    }
    
    public var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(session: viewModel.session)
                .edgesIgnoringSafeArea(.all)
            
            // Head outline overlay
            if !viewModel.isProcessing {
                HeadOutlineOverlay()
            }
            
            // Processing overlay
            if viewModel.isProcessing {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Analyzing skin...")
                        .foregroundColor(.white)
                        .padding(.top)
                }
            }
            
            // Controls overlay
            if !viewModel.isProcessing {
                VStack {
                    // Close button
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .padding()
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Capture button
                    Button(action: {
                        Task {
                            do {
                                let result = try await viewModel.captureAndAnalyze()
                                analysisResult = result
                                isPresented = false
                            } catch let error as SkinAnalysisError {
                                analysisError = error
                                isPresented = false
                            } catch {
                                analysisError = .unknown(error)
                                isPresented = false
                            }
                        }
                    }) {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .disabled(viewModel.isProcessing)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct HeadOutlineOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, geometry.size.height) * 0.8
            
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                // Transparent oval cutout
                Path { path in
                    // Draw full screen rectangle
                    path.addRect(CGRect(origin: .zero, size: geometry.size))
                    
                    // Draw oval to be cut out
                    let ovalRect = CGRect(
                        x: (geometry.size.width - width) / 2,
                        y: (geometry.size.height - width * 1.3) / 2,
                        width: width,
                        height: width * 1.3
                    )
                    path.addEllipse(in: ovalRect)
                }
                .fill(style: FillStyle(eoFill: true))
                
                // Guide text
                VStack {
                    Spacer()
                    Text("Position your face within the oval")
                        .foregroundColor(.white)
                        .padding(.bottom, 100)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct FaceCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        FaceCaptureView(
            isPresented: .constant(true),
            analysisResult: .constant(nil),
            analysisError: .constant(nil)
        )
    }
}
#endif
