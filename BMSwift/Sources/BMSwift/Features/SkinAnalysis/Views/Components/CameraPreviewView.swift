#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import AVFoundation

@available(iOS 13.0, *)
public struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    public init(session: AVCaptureSession) {
        self.session = session
    }
    
    public func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        return view
    }
    
    public func updateUIView(_ uiView: PreviewView, context: Context) {}
}

@available(iOS 13.0, *)
public class PreviewView: UIView {
    override public class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
#endif
