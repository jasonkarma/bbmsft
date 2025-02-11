#if canImport(UIKit) && os(iOS)
import SwiftUI

struct ScanningOverlayView: View {
    @State private var scanLineOffset: CGFloat = 0
    @State private var isAnimating = false
    
    private let guideColor = AppColors.primary.swiftUIColor
    private let scanLineColor = AppColors.primary.swiftUIColor.opacity(0.6)
    private let guideLineWidth: CGFloat = 2
    private let scanDuration: Double = 2.0
    private let horizontalMargin: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            let squareSize = geometry.size.width - (horizontalMargin * 2)
            
            // Group the square and scanning line together
            VStack {
                ZStack(alignment: .top) {
                    // Guide frame
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(guideColor, lineWidth: guideLineWidth)
                        .frame(width: squareSize, height: squareSize)
                    
                    // Scanning line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    scanLineColor.opacity(0),
                                    scanLineColor,
                                    scanLineColor,
                                    scanLineColor.opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: squareSize, height: 3)
                        .offset(y: scanLineOffset)
                        .blur(radius: 0.5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .position(x: geometry.size.width/2, y: geometry.size.height/2)
            .onAppear {
                // Start at the top
                scanLineOffset = 0
                
                // Animate to bottom of square
                withAnimation(
                    .linear(duration: scanDuration)
                    .repeatForever(autoreverses: true)
                ) {
                    scanLineOffset = squareSize
                }
            }
        }
    }
}

#if DEBUG
struct ScanningOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            ScanningOverlayView()
        }
        .frame(width: 400, height: 400)
        .previewLayout(.sizeThatFits)
    }
}
#endif
#endif
