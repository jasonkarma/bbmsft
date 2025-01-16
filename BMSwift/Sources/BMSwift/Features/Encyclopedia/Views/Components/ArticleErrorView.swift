#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleErrorView: View {
    @ObservedObject var viewModel: ArticleDetailViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            // Error message
            VStack(spacing: 8) {
                Text("Unable to Load Article")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Retry button
            Button {
                Task {
                    await viewModel.loadContent()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(32)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .padding()
    }
}
#endif
