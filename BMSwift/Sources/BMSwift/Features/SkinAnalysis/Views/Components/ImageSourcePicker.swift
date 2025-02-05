#if canImport(UIKit) && os(iOS)
import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
public struct ImageSourcePicker: View {
    @Binding var showSourcePicker: Bool
    let onImageSelected: (UIImage) -> Void
    
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var selectedItem: PhotosPickerItem?
    
    public init(showSourcePicker: Binding<Bool>, onImageSelected: @escaping (UIImage) -> Void) {
        self._showSourcePicker = showSourcePicker
        self.onImageSelected = onImageSelected
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Button {
                showCamera = true
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                    Text("拍攝照片")
                        .font(.headline)
                }
                .bmForegroundColor(AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .bmBackground(AppColors.secondaryBg)
                .cornerRadius(12)
            }
            
            PhotosPicker(selection: $selectedItem,
                        matching: .images) {
                HStack {
                    Image(systemName: "photo.fill")
                        .font(.title2)
                    Text("從相簿選擇")
                        .font(.headline)
                }
                .bmForegroundColor(AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .bmBackground(AppColors.secondaryBg)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .bmBackground(AppColors.primaryBg)
        .cornerRadius(16)
        .onChange(of: selectedItem) { item in
            guard let item = item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    showSourcePicker = false
                    onImageSelected(image)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                showSourcePicker = false
                onImageSelected(image)
            }
            .ignoresSafeArea()
        }
    }
}

@available(iOS 16.0, *)
private struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage) -> Void
        
        init(onImageCaptured: @escaping (UIImage) -> Void) {
            self.onImageCaptured = onImageCaptured
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            }
        }
    }
}

@available(iOS 16.0, *)
struct ImageSourcePicker_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.primaryBg.swiftUIColor.ignoresSafeArea()
            ImageSourcePicker(showSourcePicker: .constant(true)) { _ in }
        }
    }
}
#endif
