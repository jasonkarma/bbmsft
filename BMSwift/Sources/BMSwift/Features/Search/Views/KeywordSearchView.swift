#if canImport(UIKit)
import SwiftUI

@available(iOS 13.0, *)
internal struct KeywordSearchView: View {
    @ObservedObject var viewModel: KeywordSearchViewModel
    @Binding var isPresented: Bool
    
    internal init(viewModel: KeywordSearchViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
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
                        // Hot Keywords Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("熱門關鍵字清單")
                                    .font(.system(size: 14, weight: .medium))
                                    .bmForegroundColor(AppColors.primary)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.hotKeywords) { keyword in
                                        KeywordTagButton(
                                            hashtag: keyword.bp_hashtag,
                                            isSelected: viewModel.selectedHashtag == keyword.bp_hashtag
                                        ) {
                                            viewModel.selectHashtag(keyword.bp_hashtag)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 50)
                        }
                        .opacity(viewModel.selectedHashtag == nil ? 1.0 : 0.6)
                        
                        Divider()
                            .background(AppColors.gray.swiftUIColor)
                        
                        // All Keywords Section (Three lines with vertical scroll)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("全部關鍵字清單")
                                    .font(.system(size: 14, weight: .medium))
                                    .bmForegroundColor(AppColors.primary)
                                
                                if viewModel.selectedType != nil && viewModel.selectedHashtag == nil {
                                    Text("請選擇關鍵字")
                                        .font(.system(size: 14))
                                        .bmForegroundColor(AppColors.primary)
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView {
                                FlowLayout(spacing: 8) {
                                    ForEach(viewModel.allKeywords) { keyword in
                                        KeywordTagButton(
                                            hashtag: keyword.bp_hashtag,
                                            isSelected: viewModel.selectedHashtag == keyword.bp_hashtag
                                        ) {
                                            viewModel.selectHashtag(keyword.bp_hashtag)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 128)
                        }
                        .opacity(viewModel.selectedHashtag == nil ? 1.0 : 0.6)
                        
                        Divider()
                            .background(AppColors.gray.swiftUIColor)
                        
                        // Article Types Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("類型")
                                    .font(.system(size: 14, weight: .medium))
                                    .bmForegroundColor(AppColors.primary)
                                
                                if viewModel.selectedHashtag != nil && viewModel.selectedType == nil {
                                    Text("請選擇類型")
                                        .font(.system(size: 14))
                                        .bmForegroundColor(AppColors.primary)
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    KeywordTagButton(
                                        hashtag: "問題",
                                        isSelected: viewModel.selectedType == 1
                                    ) {
                                        viewModel.selectType(1)
                                    }
                                    
                                    KeywordTagButton(
                                        hashtag: "原因",
                                        isSelected: viewModel.selectedType == 2
                                    ) {
                                        viewModel.selectType(2)
                                    }
                                    
                                    KeywordTagButton(
                                        hashtag: "方法",
                                        isSelected: viewModel.selectedType == 3
                                    ) {
                                        viewModel.selectType(3)
                                    }
                                    
                                    KeywordTagButton(
                                        hashtag: "建議",
                                        isSelected: viewModel.selectedType == 4
                                    ) {
                                        viewModel.selectType(4)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 50)
                        }
                        .opacity(viewModel.selectedType == nil ? 1.0 : 0.6)
                    }
                }
            }
            .background(AppColors.black.swiftUIColor)
            .cornerRadius(12)
            .task {
                await viewModel.loadKeywords()
                if viewModel.canSearch {
                    await viewModel.performSearch()
                }
            }
            .onChange(of: viewModel.canSearch) { canSearch in
                if canSearch {
                    // Dismiss immediately when both type and keyword are selected
                    isPresented = false
                    // Start search in background
                    Task {
                        await viewModel.performSearch()
                    }
                }
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
}

#if DEBUG
@available(iOS 13.0, *)
struct KeywordSearchView_Previews: PreviewProvider {
    static var previews: some View {
        let encyclopediaVM = EncyclopediaViewModel(token: "preview-token")
        let keywordVM = KeywordSearchViewModel(
            encyclopediaViewModel: encyclopediaVM,
            token: "preview-token"
        )
        return KeywordSearchView(
            viewModel: keywordVM,
            isPresented: .constant(true)
        )
    }
}
#endif
#endif
