import SwiftUI

struct KeywordTagButton: View {
    let hashtag: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(hashtag)
                .font(.system(size: 14))
                .bmForegroundColor(AppColors.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .bmStroke(AppColors.primary.opacity(0.8), lineWidth: 1.5)
                )
        }
    }
}
