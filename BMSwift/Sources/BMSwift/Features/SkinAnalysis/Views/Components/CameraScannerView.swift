#if canImport(UIKit) && os(iOS)
import SwiftUI
import AVFoundation

public struct CameraScannerView: View {
    @StateObject private var viewModel = CameraScannerViewModel()
    @Binding private var isPresented: Bool
    private var onCapture: (UIImage) -> Void
    
    // UI Constants
    private let guideColor = AppColors.primary.swiftUIColor
    private let overlayOpacity: CGFloat = 0.5
    private let horizontalMargin: CGFloat = 10
    private let topSafeAreaInset: CGFloat = 35  // Reduced from 50 to move up
    
    public init(isPresented: Binding<Bool>, onCapture: @escaping (UIImage) -> Void) {
        self._isPresented = isPresented
        self.onCapture = onCapture
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let scanFrameSize = geometry.size.width - (horizontalMargin * 2)
            
            ZStack {
                // Background color
                Color.black
                    .ignoresSafeArea()
                
                // Camera preview
                if viewModel.showCamera, let session = viewModel.session {
                    CameraPreviewView(session: session)
                        .ignoresSafeArea()
                }
                
                // Semi-transparent overlay with cutout
                CameraOverlayShape(frameSize: scanFrameSize)
                    .fill(Color.black.opacity(overlayOpacity))
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                
                // Scanning overlay
                VStack {
                    Spacer()
                        .frame(height: 60) // Add some top spacing to move square down
                    ScanningOverlayView()
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 40)
                    
                    // Status text
                    Text(viewModel.faceDetectionStatus ?? "請保持臉部在框內")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                    
                    // Capture button
                    Button(action: {
                        viewModel.capturePhoto()
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 84, height: 84)
                            
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 74, height: 74)
                            
                            Text("拍照")
                                .font(.system(size: 19, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 50)
                }
                
                // Top overlay with close button
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                        .padding(.top, topSafeAreaInset)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.setOnCapture { image in
                onCapture(image)
                isPresented = false
            }
        }
        .onChange(of: viewModel.capturedImage) { image in
            if image != nil {
                isPresented = false
            }
        }
    }
}

#if DEBUG
struct CameraScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraScannerView(isPresented: .constant(true)) { _ in }
    }
}
#endif
#endif
