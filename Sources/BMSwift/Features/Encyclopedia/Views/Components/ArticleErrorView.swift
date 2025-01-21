#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleErrorView: View {
    @ObservedObject var viewModel: ArticleDetailViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .bmForegroundColor(AppColors.error)
            
            // Error message
            VStack(spacing: 8) {
                Text("Unable to Load Article")
                    .font(.headline)
                    .bmForegroundColor(AppColors.primaryText)
                
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .bmForegroundColor(AppColors.secondaryText)
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
                .background(AppColors.primary.swiftUIColor)
                .bmForegroundColor(AppColors.primaryText)
                .cornerRadius(8)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(32)
        .background(AppColors.secondaryBg.swiftUIColor)
        .cornerRadius(16)
        .padding()
    }
}

#if DEBUG
struct ArticleErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleErrorView(viewModel: ArticleDetailViewModel(articleId: 1, token: "preview-token"))
            .background(AppColors.primaryBg.swiftUIColor)
            .previewLayout(.sizeThatFits)
    }
}
#endif
#endif
