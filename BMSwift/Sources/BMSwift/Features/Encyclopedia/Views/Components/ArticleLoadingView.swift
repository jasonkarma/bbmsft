#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleLoadingView: View {
    @ObservedObject var viewModel: ArticleDetailViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(viewModel.comments.isEmpty ? "Loading Article..." : "Loading Comments...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ArticleEmptyView: View {
    let message: String
    let systemImage: String
    
    init(
        message: String = "No Content Available",
        systemImage: String = "doc.text"
    ) {
        self.message = message
        self.systemImage = systemImage
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text(message)
                .font(.headline)
                .foregroundColor(.primary)
            Text("Check back later for updates")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
#endif
