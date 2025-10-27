import SwiftUI

public struct Typography {
    // Headings
    static let h1 = Font.system(size: 32, weight: .bold, design: .default)
    static let h2 = Font.system(size: 28, weight: .semibold, design: .default)
    static let h3 = Font.system(size: 24, weight: .semibold, design: .default)
    
    // Body
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
    
    // Special
    static let button = Font.system(size: 16, weight: .semibold, design: .default)
    static let caption = Font.system(size: 11, weight: .regular, design: .default)
}
