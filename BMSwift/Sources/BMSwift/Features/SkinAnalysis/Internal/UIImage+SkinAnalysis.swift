import UIKit

extension UIImage {
    /// Prepares an image for skin analysis by resizing and optimizing it.
    /// - Parameter targetSize: The target size for the image
    /// - Returns: A new image that's been resized and optimized for analysis
    func preparingForAnalysis(targetSize: CGSize) -> UIImage {
        // For camera photos, check if we need to fix orientation
        let properlyOriented = fixOrientation()
        
        // Create the graphics context
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        // Calculate the rect to draw in
        let rect = CGRect(origin: .zero, size: targetSize)
        
        // Draw the image
        properlyOriented.draw(in: rect)
        
        // Get the resized image
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self // Return original if resize fails
        }
        
        return resizedImage
    }
    
    /// Fixes the orientation of an image to be up
    private func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        
        guard let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        
        return normalizedImage
    }
}
