#if canImport(UIKit) && os(iOS)
import SwiftUI

/// A reusable view for displaying errors
public struct ErrorView: View {
    let error: SkinAnalysisError
    let onRetry: () -> Void
    
    public init(error: SkinAnalysisError, onRetry: @escaping () -> Void) {
        self.error = error
        self.onRetry = onRetry
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button(action: onRetry) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: .analysisError("Failed to analyze image")) {
            // Retry action
        }
    }
}
#endif

#endif
