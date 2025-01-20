#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let isPrimary: Bool
    
    public init(isEnabled: Bool = true, isPrimary: Bool = true) {
        self.isEnabled = isEnabled
        self.isPrimary = isPrimary
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor.swiftUIColor)
            )
            .foregroundColor(foregroundColor.swiftUIColor)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
    
    private var backgroundColor: BMColor {
        if !isEnabled {
            return AppColors.thirdBg
        }
        return isPrimary ? AppColors.primary : AppColors.secondary
    }
    
    private var foregroundColor: BMColor {
        if !isEnabled {
            return AppColors.lightText
        }
        return isPrimary ? AppColors.lightText : AppColors.darkText
    }
}

@available(iOS 13.0, *)
public extension View {
    func primaryButtonStyle(isEnabled: Bool = true, isPrimary: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled, isPrimary: isPrimary))
    }
}
#endif
