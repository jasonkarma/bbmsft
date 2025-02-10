#if canImport(UIKit) && os(iOS)
import SwiftUI
import AVFoundation

public struct CameraScannerView: View {
    @StateObject private var viewModel = CameraScannerViewModel()
    @Binding private var isPresented: Bool
    private var onCapture: (UIImage) -> Void
    
    // Face detection guide
    private let guideColor = AppColors.primary.swiftUIColor
    private let guideLineWidth: CGFloat = 2
    private let optimalFaceRatio: CGFloat = 0.6
    
    public init(isPresented: Binding<Bool>, onCapture: @escaping (UIImage) -> Void) {
        self._isPresented = isPresented
        self.onCapture = onCapture
    }
    
    public var body: some View {
        ZStack {
            // Background color
            AppColors.primaryBg.swiftUIColor
                .ignoresSafeArea()
            
            // Camera preview
            if viewModel.showCamera {
                CameraPreviewView(session: viewModel.session)
                    .ignoresSafeArea()
            }
            
            // Face detection guide overlay
            VStack {
                Spacer()
                ZStack {
                    // Outer border
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(guideColor, lineWidth: guideLineWidth)
                        .frame(width: 280, height: 280)
                    
                    // Face outline
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160, height: 160)
                        .foregroundColor(guideColor.opacity(0.3))
                    
                    // Face detection status indicator
                    if let faceRect = viewModel.detectedFaceRect {
                        Rectangle()
                            .stroke(viewModel.isFacePositionValid ? .green : .red, lineWidth: 2)
                            .frame(
                                width: faceRect.width * UIScreen.main.bounds.width,
                                height: faceRect.height * UIScreen.main.bounds.height
                            )
                            .position(
                                x: faceRect.midX * UIScreen.main.bounds.width,
                                y: faceRect.midY * UIScreen.main.bounds.height
                            )
                    }
                }
                .padding(.bottom, 100)
                
                // Status text
                Text(viewModel.faceDetectionStatus ?? "請保持臉部在框內")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(guideColor)
                    .padding(.bottom, 20)
                
                // Capture button
                Button(action: {
                    viewModel.capturePhoto()
                }) {
                    ZStack {
                        Circle()
                            .stroke(guideColor, lineWidth: 3)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(guideColor.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        Text("拍照")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(guideColor)
                    }
                }
                .disabled(!viewModel.isFacePositionValid)
                .padding(.bottom, 40)
            }
            
            // Top overlay with guide text
            VStack {
                Text("請將臉部對準框內")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(guideColor)
                    .padding(.top, 20)
                Spacer()
            }
        }
        .onAppear {
            viewModel.setOnCapture(onCapture)
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
