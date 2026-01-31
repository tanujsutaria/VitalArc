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

    // MARK: - Text on Colored Backgrounds

    /// Use for text on primary, secondary, or gradient backgrounds
    static let vitalTextOnPrimary = Color.white

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

    static let vitalInfoGradient = LinearGradient(
        colors: [vitalInfo, Color(hex: "#0284C7")],
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

    // MARK: - Opacity Convenience Methods

    /// Apply very light opacity (0.1) - subtle backgrounds
    func vitalVeryLight() -> Color { self.opacity(ColorOpacity.veryLight) }

    /// Apply light opacity (0.15) - icon backgrounds, badges
    func vitalLight() -> Color { self.opacity(ColorOpacity.light) }

    /// Apply medium opacity (0.3) - overlays, disabled states
    func vitalMedium() -> Color { self.opacity(ColorOpacity.medium) }

    /// Apply heavy opacity (0.5) - semi-transparent overlays
    func vitalHeavy() -> Color { self.opacity(ColorOpacity.heavy) }
}

// MARK: - Opacity Tokens

/// Semantic opacity values for consistent transparency across the app
enum ColorOpacity {
    /// Very subtle backgrounds (0.1)
    static let veryLight: Double = 0.1

    /// Icon backgrounds, badges, subtle highlights (0.15)
    static let light: Double = 0.15

    /// Overlays, disabled states (0.3)
    static let medium: Double = 0.3

    /// Semi-transparent overlays (0.5)
    static let heavy: Double = 0.5
}

// MARK: - V2 Premium Design System Colors

extension Color {
    // MARK: - V2 Primary Palette (WHOOP-inspired)

    /// Strain Red - Primary action color for V2 design
    static let vitalPrimaryV2 = Color(hex: "#E63946")

    /// Deep Navy - Secondary color for V2 design
    static let vitalSecondaryV2 = Color(hex: "#1E3A5F")

    /// Cyan - Accent color for highlights and data emphasis
    static let vitalAccentV2 = Color(hex: "#00D4FF")

    // MARK: - V2 Functional Colors

    /// Recovery Green - Success states
    static let vitalSuccessV2 = Color(hex: "#00C853")

    /// Warning amber (unchanged from V1)
    static let vitalWarningV2 = Color(hex: "#F59E0B")

    /// Danger red (slightly different from primary for clarity)
    static let vitalDangerV2 = Color(hex: "#FF3B30")

    /// Info blue - Informational highlights
    static let vitalInfoV2 = Color(hex: "#0A84FF")

    // MARK: - V2 Neutral Palette (Deep Black Theme)

    /// Deep Black - Primary background
    static let vitalBackgroundV2 = Color(hex: "#0A0A0C")

    /// Elevated Black - Card/surface background
    static let vitalSurfaceV2 = Color(hex: "#141418")

    /// Raised surface level
    static let vitalSurfaceRaisedV2 = Color(hex: "#1C1C22")

    /// Elevated surface level
    static let vitalSurfaceElevatedV2 = Color(hex: "#242428")

    /// Border color for V2 dark theme
    static let vitalBorderV2 = Color(hex: "#2A2A30")

    /// Subtle border/divider
    static let vitalBorderSubtleV2 = Color(hex: "#1E1E24")

    // MARK: - V2 Text Colors (Dark Theme)

    /// Primary text on dark backgrounds
    static let vitalTextPrimaryV2 = Color(hex: "#FFFFFF")

    /// Secondary text on dark backgrounds
    static let vitalTextSecondaryV2 = Color(hex: "#A0A0A8")

    /// Tertiary/muted text
    static let vitalTextTertiaryV2 = Color(hex: "#6E6E78")

    /// Placeholder text
    static let vitalTextPlaceholderV2 = Color(hex: "#4A4A52")

    // MARK: - V2 Light Mode Palette

    /// Light mode background
    static let vitalBackgroundLightV2 = Color(hex: "#F5F5F7")

    /// Light mode surface
    static let vitalSurfaceLightV2 = Color.white

    /// Light mode border
    static let vitalBorderLightV2 = Color(hex: "#E0E0E5")

    /// Light mode primary text
    static let vitalTextPrimaryLightV2 = Color(hex: "#0A0A0C")

    /// Light mode secondary text
    static let vitalTextSecondaryLightV2 = Color(hex: "#6E6E78")

    // MARK: - V2 Adaptive Colors

    static var vitalAdaptiveBackgroundV2: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalBackgroundV2)
                : UIColor(Color.vitalBackgroundLightV2)
        })
    }

    static var vitalAdaptiveSurfaceV2: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalSurfaceV2)
                : UIColor(Color.vitalSurfaceLightV2)
        })
    }

    static var vitalAdaptiveSurfaceRaisedV2: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalSurfaceRaisedV2)
                : UIColor(Color.white)
        })
    }

    static var vitalAdaptiveSurfaceElevatedV2: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalSurfaceElevatedV2)
                : UIColor(Color.white)
        })
    }

    static var vitalAdaptiveBorderV2: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalBorderV2)
                : UIColor(Color.vitalBorderLightV2)
        })
    }

    static var vitalAdaptiveTextPrimaryV2: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalTextPrimaryV2)
                : UIColor(Color.vitalTextPrimaryLightV2)
        })
    }

    static var vitalAdaptiveTextSecondaryV2: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalTextSecondaryV2)
                : UIColor(Color.vitalTextSecondaryLightV2)
        })
    }

    static var vitalAdaptiveTextTertiaryV2: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color.vitalTextTertiaryV2)
                : UIColor(Color(hex: "#9CA3AF"))
        })
    }

    // MARK: - V2 Gradients

    /// Primary gradient (Strain Red to Coral)
    static let vitalPrimaryGradientV2 = LinearGradient(
        colors: [Color(hex: "#E63946"), Color(hex: "#FF6B6B")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Accent gradient (Cyan to Blue)
    static let vitalAccentGradientV2 = LinearGradient(
        colors: [Color(hex: "#00D4FF"), Color(hex: "#0A84FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Success gradient (Recovery Green variations)
    static let vitalSuccessGradientV2 = LinearGradient(
        colors: [Color(hex: "#00C853"), Color(hex: "#00E676")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Dark surface gradient (subtle depth)
    static let vitalSurfaceGradientV2 = LinearGradient(
        colors: [Color(hex: "#141418"), Color(hex: "#1C1C22")],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Premium gradient (deep blue to purple)
    static let vitalPremiumGradientV2 = LinearGradient(
        colors: [Color(hex: "#1E3A5F"), Color(hex: "#4A2C7A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - V2 Glow Colors (for dark mode effects)

    /// Primary glow color
    static let vitalPrimaryGlowV2 = Color(hex: "#E63946").opacity(0.4)

    /// Accent glow color
    static let vitalAccentGlowV2 = Color(hex: "#00D4FF").opacity(0.4)

    /// Success glow color
    static let vitalSuccessGlowV2 = Color(hex: "#00C853").opacity(0.4)

    /// Inner glow for cards (subtle white highlight)
    static let vitalInnerGlowV2 = Color.white.opacity(0.05)
}
