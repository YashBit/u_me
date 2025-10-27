import SwiftUI

public enum Colors {
    // Brand Colors
    static let primary = Color(hex: "#7B2CBF")     // Purple
    static let secondary = Color(hex: "#FF6B6B")   // Coral
    
    // Semantic Colors
    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FFC107")
    static let error = Color(hex: "#F44336")
    
    // Neutral Colors
    static let text = Color(hex: "#1A1A1A")
    static let textSecondary = Color(hex: "#757575")
    static let background = Color(hex: "#FFFFFF")
    static let surface = Color(hex: "#F5F5F5")
}

extension Color {
    init(hex: String) {
        // Hex to Color conversion
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
