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
                backgroundColor(isEnabled: isEnabled, isPrimary: isPrimary)
            )
            .foregroundColor(
                foregroundColor(isEnabled: isEnabled, isPrimary: isPrimary)
            )
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
    
    private func backgroundColor(isEnabled: Bool, isPrimary: Bool) -> Color {
        if !isEnabled {
            return AppColors.thirdBg
        }
        return isPrimary ? AppColors.primary : AppColors.secondary
    }
    
    private func foregroundColor(isEnabled: Bool, isPrimary: Bool) -> Color {
        if !isEnabled {
            return .white
        }
        return isPrimary ? .black : .white
    }
}

@available(iOS 13.0, *)
public extension View {
    func primaryButtonStyle(isEnabled: Bool = true, isPrimary: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled, isPrimary: isPrimary))
    }
}
#endif
