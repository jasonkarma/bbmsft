#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import AVFoundation
import UIKit

// MARK: - Camera Scanner View
public struct CameraScannerView: View {
    // MARK: - Properties
    @StateObject private var viewModel: CameraScannerViewModel
    
    // MARK: - Initialization
    public init(onPhotoCapture: @escaping (UIImage) -> Void) {
        _viewModel = StateObject(wrappedValue: CameraScannerViewModel(onPhotoCapture: onPhotoCapture))
    }
    
    // MARK: - Body
    public var body: some View {
        ZStack {
            if viewModel.isAuthorized {
                CameraPreviewView(session: viewModel.session)
                    .overlay(alignment: .bottom) {
                        controlsOverlay
                    }
            } else {
                Text("Camera access required")
                    .foregroundColor(.red)
            }
        }
        .background(Color(uiColor: .systemBackground))
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
    
    // MARK: - Private Views
    private var controlsOverlay: some View {
        HStack(spacing: 16) {
            if viewModel.isFlashAvailable {
                Button(action: viewModel.toggleFlash) {
                    Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            Button(action: viewModel.capturePhoto) {
                Circle()
                    .strokeBorder(Color.blue, lineWidth: 3)
                    .frame(width: 72, height: 72)
            }
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Preview Provider
struct CameraScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraScannerView { _ in }
    }
}
#endif
