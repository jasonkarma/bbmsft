import SwiftUI

public struct KeywordTagButton: View {
    let hashtag: String
    let action: () -> Void
    let isSelected: Bool
    
    public init(hashtag: String, isSelected: Bool = false, action: @escaping () -> Void) {
        self.hashtag = hashtag
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(hashtag)
                .font(.system(size: 14))
                .bmForegroundColor(isSelected ? AppColors.black : AppColors.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.primary.swiftUIColor, lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? AppColors.primary.swiftUIColor : Color.clear)
                        )
                )
        }
    }
}
