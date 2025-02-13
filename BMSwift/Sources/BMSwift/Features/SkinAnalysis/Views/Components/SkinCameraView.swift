#if canImport(UIKit) && os(iOS)
import SwiftUI
import AVFoundation

public struct SkinCameraView: View {
    @ObservedObject var viewModel: FaceCaptureViewModel
    let onCapture: (UIImage) -> Void
    
    public init(viewModel: FaceCaptureViewModel, onCapture: @escaping (UIImage) -> Void) {
        self.viewModel = viewModel
        self.onCapture = onCapture
    }
    
    public var body: some View {
        ZStack {
            SkinCameraPreviewView(session: viewModel.session)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    Button {
                        viewModel.zoomOut()
                    } label: {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Button {
                        Task {
                            do {
                                let image = try await viewModel.capturePhoto()
                                onCapture(image)
                            } catch {
                                // Handle error
                            }
                        }
                    } label: {
                        Image(systemName: "camera.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(.white)
                    }
                    .disabled(viewModel.isProcessing)
                    
                    Button {
                        viewModel.zoomIn()
                    } label: {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }
}

public struct SkinCameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    public init(session: AVCaptureSession) {
        self.session = session
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect.zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiView.bounds
        }
    }
}
#endif
