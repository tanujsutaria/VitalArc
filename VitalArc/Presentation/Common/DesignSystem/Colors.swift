//
//  Colors.swift
//  VitalArc
//
//  VitalArc Design System - Color Palette
//

import SwiftUI

extension Color {
    // MARK: - Primary Palette

    static let vitalPrimary = Color(hex: "#6366F1") // Indigo
    static let vitalSecondary = Color(hex: "#8B5CF6") // Purple
    static let vitalAccent = Color(hex: "#EC4899") // Pink

    // MARK: - Functional Colors

    static let vitalSuccess = Color(hex: "#10B981") // Green
    static let vitalWarning = Color(hex: "#F59E0B") // Amber
    static let vitalDanger = Color(hex: "#EF4444") // Red
    static let vitalInfo = Color(hex: "#3B82F6") // Blue

    // MARK: - Neutrals (Light Mode)

    static let vitalBackground = Color(hex: "#F9FAFB")
    static let vitalSurface = Color.white
    static let vitalBorder = Color(hex: "#E5E7EB")

    // MARK: - Text (Light Mode)

    static let vitalTextPrimary = Color(hex: "#111827")
    static let vitalTextSecondary = Color(hex: "#6B7280")
    static let vitalTextTertiary = Color(hex: "#9CA3AF")

    // MARK: - Dark Mode Variants

    static let vitalBackgroundDark = Color(hex: "#111827")
    static let vitalSurfaceDark = Color(hex: "#1F2937")
    static let vitalBorderDark = Color(hex: "#374151")

    // MARK: - Adaptive Colors

    static var vitalAdaptiveBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalBackgroundDark)
                : UIColor(Color.vitalBackground)
        })
    }

    static var vitalAdaptiveSurface: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalSurfaceDark)
                : UIColor(Color.vitalSurface)
        })
    }

    static var vitalAdaptiveBorder: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalBorderDark)
                : UIColor(Color.vitalBorder)
        })
    }

    static var vitalAdaptiveTextPrimary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? .white
                : UIColor(Color.vitalTextPrimary)
        })
    }

    static var vitalAdaptiveTextSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "#D1D5DB"))
                : UIColor(Color.vitalTextSecondary)
        })
    }

    static var vitalAdaptiveTextTertiary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "#9CA3AF"))
                : UIColor(Color.vitalTextTertiary)
        })
    }

    // MARK: - Gradient Backgrounds

    static let vitalPrimaryGradient = LinearGradient(
        colors: [vitalPrimary, vitalSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let vitalAccentGradient = LinearGradient(
        colors: [vitalSecondary, vitalAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let vitalSuccessGradient = LinearGradient(
        colors: [vitalSuccess, Color(hex: "#059669")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Hex Color Initializer

    init(hex: String) {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
