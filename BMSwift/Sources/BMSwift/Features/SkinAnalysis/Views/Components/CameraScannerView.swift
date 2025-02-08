#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import AVFoundation
import UIKit
import Vision

@available(iOS 16.0, *)
public struct CameraScannerView: View {
    @StateObject private var viewModel: CameraScannerViewModel
    @Binding private var isPresented: Bool
    
    // Face detection guide
    private let guideColor = Color.white
    private let guideLineWidth: CGFloat = 2
    private let guideDashPattern: [CGFloat] = [5, 5]
    private let optimalFaceRatio: CGFloat = 0.6
    
    public init(isPresented: Binding<Bool>, onCapture: @escaping (UIImage) -> Void) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: CameraScannerViewModel())
        viewModel.setOnCapture(onCapture)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera preview
                if viewModel.showCamera {
                    CameraPreviewView(session: viewModel.session)
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Face detection overlay
                FaceDetectionOverlay(
                    faceRect: viewModel.detectedFaceRect,
                    frameSize: geometry.size,
                    guideColor: guideColor,
                    lineWidth: guideLineWidth,
                    dashPattern: guideDashPattern
                )
                
                // Controls overlay
                VStack {
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
                    
                    // Status message
                    if let status = viewModel.faceDetectionStatus {
                        Text(status)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                    }
                    
                    // Capture button
                    if viewModel.showCamera && viewModel.isFacePositionValid {
                        Button(action: viewModel.capturePhoto) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: 80, height: 80)
                                )
                        }
                        .disabled(viewModel.state == .capturing)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .alert(
            "Camera Access Required",
            isPresented: .constant(viewModel.state.error?.errorDescription != nil),
            actions: {
                Button("Settings", action: viewModel.openSettings)
                Button("Cancel", role: .cancel) { isPresented = false }
            },
            message: {
                if let error = viewModel.state.error {
                    Text(error.errorDescription ?? "")
                }
            }
        )
        .onAppear {
            Task {
                await viewModel.checkCameraAuthorization()
            }
        }
    }
}

struct FaceDetectionOverlay: View {
    let faceRect: CGRect?
    let frameSize: CGSize
    let guideColor: Color
    let lineWidth: CGFloat
    let dashPattern: [CGFloat]
    
    private let optimalFaceSize: CGSize = CGSize(width: 0.6, height: 0.6)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Guide rectangle
                Path { path in
                    let guideRect = CGRect(
                        x: frameSize.width * (0.5 - optimalFaceSize.width/2),
                        y: frameSize.height * (0.5 - optimalFaceSize.height/2),
                        width: frameSize.width * optimalFaceSize.width,
                        height: frameSize.height * optimalFaceSize.height
                    )
                    path.addRect(guideRect)
                }
                .stroke(style: StrokeStyle(
                    lineWidth: lineWidth,
                    dash: dashPattern
                ))
                .foregroundColor(guideColor)
                
                // Face rectangle (if detected)
                if let faceRect = faceRect {
                    Path { path in
                        path.addRect(faceRect)
                    }
                    .stroke(Color.green, lineWidth: lineWidth)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0.0, *)
struct CameraScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraScannerView(isPresented: .constant(true)) { _ in }
    }
}
#endif
#endif
