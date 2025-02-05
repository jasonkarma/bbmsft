#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import AVFoundation
import UIKit

@available(iOS 13.0, *)
public struct CameraScannerView: View {
    private let onCapture: (UIImage) -> Void
    @StateObject private var viewModel: CameraScannerViewModel
    
    public init(onCapture: @escaping (UIImage) -> Void) {
        self.onCapture = onCapture
        self._viewModel = StateObject(wrappedValue: CameraScannerViewModel(onCapture: onCapture))
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreviewView(session: viewModel.session)
                    .edgesIgnoringSafeArea(.all)
                
                // Overlay mask
                Path { path in
                    let rect = CGRect(origin: .zero, size: geometry.size)
                    path.addRect(rect)
                    
                    let centerSize = min(geometry.size.width, geometry.size.height) * 0.7
                    let centerRect = CGRect(
                        x: (geometry.size.width - centerSize) / 2,
                        y: (geometry.size.height - centerSize) / 2,
                        width: centerSize,
                        height: centerSize
                    )
                    path.addRoundedRect(in: centerRect, cornerSize: CGSize(width: 20, height: 20))
                }
                .fill(style: FillStyle(eoFill: true))
                .foregroundColor(AppColors.primaryBg.swiftUIColor.opacity(0.6))
                
                // Scan frame
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.primary.swiftUIColor, lineWidth: 3)
                    .frame(
                        width: min(geometry.size.width, geometry.size.height) * 0.7,
                        height: min(geometry.size.width, geometry.size.height) * 0.7
                    )
                
                // Capture button
                VStack {
                    Spacer()
                    Button(action: viewModel.capturePhoto) {
                        Circle()
                            .fill(AppColors.primary.swiftUIColor)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .strokeBorder(AppColors.primary.swiftUIColor, lineWidth: 4)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            viewModel.checkPermissions()
        }
        .onChange(of: viewModel.photo) { photo in
            if let photo = photo {
                onCapture(photo)
            }
        }
        .alert("需要相機權限", isPresented: $viewModel.showPermissionAlert) {
            Button("前往設置", role: .none) {
                viewModel.openAppSettings()
            }
            .foregroundColor(AppColors.primary.swiftUIColor)
            
            Button("取消", role: .cancel) {}
                .foregroundColor(AppColors.primaryText.swiftUIColor)
        } message: {
            Text("請在設置中允許使用相機")
                .foregroundColor(AppColors.secondaryText.swiftUIColor)
        }
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct CameraScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraScannerView { _ in }
    }
}
#endif
#endif
