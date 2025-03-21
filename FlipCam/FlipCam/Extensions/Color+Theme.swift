import SwiftUI

extension Color {
    static func themeAccent(colorScheme: ColorScheme) -> Color {
		colorScheme == .dark ? .yellow : Color(hex: "1BA3CE")
    }
    
    static func themeAccentWithOpacity(colorScheme: ColorScheme, opacity: Double = 0.7) -> Color {
        themeAccent(colorScheme: colorScheme).opacity(opacity)
    }
    
    static func themeForeground(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : Color.gray
    }
} 
