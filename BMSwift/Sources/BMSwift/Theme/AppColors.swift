#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public enum AppColors {
    // Main colors
    public static let primary = Color(hex: "#3AB597")
    public static let secondary = Color(hex: "#d4d4d8")
    
    // Text colors
    public static let primaryText = Color(hex: "#05221B")
    
    // Background colors
    public static let primaryBg = Color.black
    public static let secondaryBg = Color(hex: "#DEF4F2")
    public static let thirdBg = Color(hex: "#a9a9ab")
    
    // Highlight colors
    public static let highlight = Color(hex: "#E1972D")
    
    // System colors
    public static let error = Color.red
    public static let success = Color.green
    public static let warning = Color.orange
}

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
#endif
