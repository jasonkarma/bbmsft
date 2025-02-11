#if canImport(UIKit) && os(iOS)
import SwiftUI

struct CameraOverlayShape: Shape {
    let frameSize: CGFloat
    let cornerRadius: CGFloat
    let verticalOffset: CGFloat
    let borderWidth: CGFloat
    
    init(
        frameSize: CGFloat,  
        cornerRadius: CGFloat = 12,
        verticalOffset: CGFloat = -20,
        borderWidth: CGFloat = 1.5
    ) {
        self.frameSize = frameSize
        self.cornerRadius = cornerRadius
        self.verticalOffset = verticalOffset
        self.borderWidth = borderWidth
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Outer rectangle (full screen)
        path.addRect(rect)
        
        // Inner cutout (centered square)
        let origin = CGPoint(
            x: (rect.width - frameSize) / 2,
            y: (rect.height - frameSize) / 2 + verticalOffset
        )
        let cutout = CGRect(
            origin: origin,
            size: CGSize(width: frameSize, height: frameSize)
        )
        
        // Create a separate path for the cutout with rounded corners
        let cutoutPath = Path(roundedRect: cutout, cornerRadius: cornerRadius)
        
        // Subtract the cutout from the main path
        path.addPath(cutoutPath)
        
        return path
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main overlay with cutout
                self.path(in: geometry.frame(in: .local))
                    .fill(style: FillStyle(eoFill: true))
                
                // Subtle border around the cutout
                let origin = CGPoint(
                    x: (geometry.size.width - frameSize) / 2,
                    y: (geometry.size.height - frameSize) / 2 + verticalOffset
                )
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.3), lineWidth: borderWidth)
                    .frame(width: frameSize, height: frameSize)
                    .position(x: origin.x + frameSize/2, y: origin.y + frameSize/2)
            }
        }
    }
}

#if DEBUG
struct CameraOverlayShape_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            CameraOverlayShape(frameSize: UIScreen.main.bounds.width * 0.8) 
                .fill(Color.black.opacity(0.4))
        }
        .ignoresSafeArea()
        .previewLayout(.sizeThatFits)
    }
}
#endif
#endif
