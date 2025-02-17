#if canImport(UIKit)
import SwiftUI

@available(iOS 13.0, *)
internal struct KeywordSearchView: View {
    @StateObject private var viewModel: KeywordSearchViewModel
    @Binding var isPresented: Bool
    
    internal init(token: String, encyclopediaViewModel: EncyclopediaViewModel, isPresented: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: KeywordSearchViewModel(
            service: EncyclopediaService(client: .shared),
            token: token,
            encyclopediaViewModel: encyclopediaViewModel
        ))
        self._isPresented = isPresented
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Text("關鍵字搜尋")
                    .font(.system(size: 16, weight: .medium))
                    .bmForegroundColor(AppColors.primary)
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .bmForegroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(AppColors.black.swiftUIColor)
            
            switch viewModel.state {
            case .loading:
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryText.swiftUIColor))
                        .scaleEffect(1.5)
                }
                .frame(height: 200)
                
            case .error(let error):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .bmForegroundColor(AppColors.warning)
                    
                    Text(error.localizedDescription)
                        .bmForegroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            await viewModel.loadKeywords()
                        }
                    }) {
                        Text("重試")
                            .bmForegroundColor(AppColors.primaryText)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AppColors.primary.swiftUIColor)
                            .cornerRadius(8)
                    }
                }
                .frame(height: 200)
                
            case .loaded:
                VStack(spacing: 16) {
                    // Hot Keywords Section (Single line)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("熱門關鍵字清單")
                            .font(.system(size: 14, weight: .medium))
                            .bmForegroundColor(AppColors.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.hotKeywords) { keyword in
                                    KeywordTagButton(hashtag: keyword.bp_hashtag) {
                                        viewModel.keywordSelected(keyword)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(height: 32)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .background(AppColors.gray.swiftUIColor)
                    
                    // All Keywords Section (Three lines with vertical scroll)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("全部關鍵字清單")
                            .font(.system(size: 14, weight: .medium))
                            .bmForegroundColor(AppColors.primary)
                        
                        ScrollView {
                            FlowLayout(spacing: 8) {
                                ForEach(viewModel.allKeywords) { keyword in
                                    KeywordTagButton(hashtag: keyword.bp_hashtag) {
                                        viewModel.keywordSelected(keyword)
                                    }
                                }
                            }
                        }
                        .frame(height: 96) // 3 lines of tags (32 * 3)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(AppColors.black.swiftUIColor)
        .cornerRadius(12)
        .task {
            await viewModel.loadKeywords()
        }
    }
}

// FlowLayout to arrange tags in a flowing manner
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var height: CGFloat = 0
        var currentRow: CGFloat = 0
        var currentX: CGFloat = 0
        let width = proposal.width ?? .infinity
        
        for size in sizes {
            if currentX + size.width > width {
                height += currentRow + spacing
                currentRow = size.height
                currentX = size.width + spacing
            } else {
                currentRow = max(currentRow, size.height)
                currentX += size.width + spacing
            }
        }
        height += currentRow
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(size)
            )
            
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct KeywordSearchView_Previews: PreviewProvider {
    static var previews: some View {
        KeywordSearchView(
            token: "preview-token",
            encyclopediaViewModel: EncyclopediaViewModel(token: "preview-token"),
            isPresented: .constant(true)
        )
    }
}
#endif
#endif
