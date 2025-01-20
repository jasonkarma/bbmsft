#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import UIKit

@available(iOS 13.0, *)
public struct BMColor {
    // MARK: - Properties
    private let red: CGFloat
    private let green: CGFloat
    private let blue: CGFloat
    private let alpha: CGFloat
    
    // MARK: - Initialization
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    // MARK: - Color Properties
    public var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    internal var swiftUIColor: SwiftUI.Color {
        SwiftUI.Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
    
    // MARK: - SwiftUI Helpers
    public func opacity(_ value: Double) -> BMColor {
        BMColor(red: red, green: green, blue: blue, alpha: CGFloat(value))
    }
    
    public static var clear: BMColor {
        BMColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
}

@available(iOS 13.0, *)
public extension View {
    func bmForegroundColor(_ color: BMColor) -> some View {
        self.foregroundColor(color.swiftUIColor)
    }
    
    func bmBackground(_ color: BMColor) -> some View {
        self.background(color.swiftUIColor)
    }
}

@available(iOS 13.0, *)
extension Shape {
    public func bmFill(_ color: BMColor) -> some View {
        self.fill(color.swiftUIColor)
    }
    
    public func bmStroke(_ color: BMColor, lineWidth: CGFloat = 1) -> some View {
        self.stroke(color.swiftUIColor, lineWidth: lineWidth)
    }
}

@available(iOS 13.0, *)
public enum AppColors {
    // MARK: - Main Colors
    public static var primary: BMColor {
        BMColor(red: 0.227, green: 0.710, blue: 0.592)  // #3AB597
    }
    public static var secondary: BMColor {
        BMColor(red: 0.831, green: 0.831, blue: 0.847)  // #d4d4d8
    }
    
    // MARK: - Text Colors
    public static var primaryText: BMColor {
        BMColor(red: 0.020, green: 0.133, blue: 0.106)  // #05221B
    }
    public static var secondaryText: BMColor {
        BMColor(red: 0.6, green: 0.6, blue: 0.6)  // #999999
    }
    public static var lightText: BMColor {
        BMColor(red: 1, green: 1, blue: 1)
    }
    public static var darkText: BMColor {
        BMColor(red: 0, green: 0, blue: 0)
    }
    
    // MARK: - Background Colors
    public static var primaryBg: BMColor {
        BMColor(red: 0, green: 0, blue: 0)
    }
    public static var secondaryBg: BMColor {
        BMColor(red: 0.871, green: 0.957, blue: 0.949)  // #DEF4F2
    }
    public static var thirdBg: BMColor {
        BMColor(red: 0.663, green: 0.663, blue: 0.671)  // #a9a9ab
    }
    
    // MARK: - Highlight Colors
    public static var highlight: BMColor {
        BMColor(red: 0.882, green: 0.592, blue: 0.176)  // #E1972D
    }
    
    // MARK: - System Colors
    public static var error: BMColor {
        BMColor(red: 1, green: 0, blue: 0)
    }
    public static var success: BMColor {
        BMColor(red: 0, green: 0.8, blue: 0)
    }
    public static var warning: BMColor {
        BMColor(red: 1, green: 0.5, blue: 0)
    }
    public static var red: BMColor {
        BMColor(red: 1, green: 0, blue: 0)  // #FF0000
    }
    
    // MARK: - Basic Colors
    public static var black: BMColor {
        BMColor(red: 0, green: 0, blue: 0)  // #000000
    }
    public static var white: BMColor {
        BMColor(red: 1, green: 1, blue: 1)  // #FFFFFF
    }
    public static var blue: BMColor {
        BMColor(red: 0, green: 0.478, blue: 1)  // #007AFF
    }
    public static var gray: BMColor {
        BMColor(red: 128/255, green: 128/255, blue: 128/255)
    }
}

// MARK: - UIKit Extensions
public extension UIView {
    func setBackgroundColor(_ color: BMColor) {
        backgroundColor = color.uiColor
    }
}

public extension UIColor {
    static var bmPrimary: UIColor { AppColors.primary.uiColor }
    static var bmSecondary: UIColor { AppColors.secondary.uiColor }
    static var bmPrimaryText: UIColor { AppColors.primaryText.uiColor }
    static var bmSecondaryText: UIColor { AppColors.secondaryText.uiColor }
    static var bmLightText: UIColor { AppColors.lightText.uiColor }
    static var bmDarkText: UIColor { AppColors.darkText.uiColor }
    static var bmPrimaryBg: UIColor { AppColors.primaryBg.uiColor }
    static var bmSecondaryBg: UIColor { AppColors.secondaryBg.uiColor }
    static var bmThirdBg: UIColor { AppColors.thirdBg.uiColor }
    static var bmHighlight: UIColor { AppColors.highlight.uiColor }
    static var bmError: UIColor { AppColors.error.uiColor }
    static var bmSuccess: UIColor { AppColors.success.uiColor }
    static var bmWarning: UIColor { AppColors.warning.uiColor }
    static var bmWhite: UIColor { AppColors.white.uiColor }
    static var bmBlack: UIColor { AppColors.black.uiColor }
    static var bmBlue: UIColor { AppColors.blue.uiColor }
    static var bmRed: UIColor { AppColors.red.uiColor }
    static var bmGray: UIColor { AppColors.gray.uiColor }
}
#endif
