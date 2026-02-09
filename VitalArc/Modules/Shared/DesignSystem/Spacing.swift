//
//  Spacing.swift
//  VitalArc
//
//  VitalArc Design System - Spacing Scale
//

import SwiftUI

enum Spacing {
    // MARK: - Base Spacing Scale

    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64

    // MARK: - Semantic Spacing

    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
    static let itemSpacing: CGFloat = 12

    // MARK: - Corner Radius

    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXLarge: CGFloat = 24

    // MARK: - Icon Sizes
    // Used for SF Symbol icons via .font(.system(size:))

    static let iconTiny: CGFloat = 10      // Badges, indicators
    static let iconXSmall: CGFloat = 12    // Small badges
    static let iconSmall: CGFloat = 16     // Inline icons
    static let iconMedium: CGFloat = 20    // Standard icons
    static let iconLarge: CGFloat = 24     // Prominent icons
    static let iconXLarge: CGFloat = 32    // Section headers
    static let icon2XLarge: CGFloat = 40   // Chart/card icons
    static let iconHuge: CGFloat = 48      // Empty states
    static let iconGiant: CGFloat = 60     // Hero sections
    static let iconHero: CGFloat = 64      // Large empty states

    // MARK: - Illustration Sizes
    // For hero icons, onboarding illustrations, empty states

    static let illustrationSmall: CGFloat = 80     // Small empty states
    static let illustrationMedium: CGFloat = 100   // Standard empty states
    static let illustrationLarge: CGFloat = 120    // Hero sections
    static let illustrationXLarge: CGFloat = 140   // Welcome/onboarding

    // MARK: - Avatar Sizes

    static let avatarSmall: CGFloat = 40   // List items, compact views
    static let avatarMedium: CGFloat = 48  // Cards, stat items
    static let avatarLargish: CGFloat = 56 // Header icons in sheets
    static let avatarLarge: CGFloat = 64   // Profile headers (compact)
    static let avatarXLarge: CGFloat = 100 // Profile avatar inner
    static let avatarXLargeBorder: CGFloat = 108  // Profile avatar border
    static let avatarXLargeOuter: CGFloat = 116   // Profile avatar outer

    // MARK: - Border Width

    static let borderThin: CGFloat = 1
    static let borderMedium: CGFloat = 2
    static let borderThick: CGFloat = 3

    // MARK: - Chart Heights

    static let chartHeightCompact: CGFloat = 120   // Small inline charts
    static let chartHeightSmall: CGFloat = 150     // Trend charts
    static let chartHeightMedium: CGFloat = 160    // Standard charts
    static let chartHeightLarge: CGFloat = 180     // Featured charts
    static let chartHeightExtraLarge: CGFloat = 200  // Standard featured charts
    static let chartHeightXL: CGFloat = 250           // Volume distribution charts

    // MARK: - Component Widths

    static let pickerWidthCompact: CGFloat = 150   // Segmented pickers

    // MARK: - Component Heights
    static let progressBarHeight: CGFloat = 6         // Macro progress bars
    static let quickActionCardHeight: CGFloat = 80    // Dashboard quick action cards

    // MARK: - Chart Sizes

    static let pieChartSize: CGFloat = 140         // Pie/donut chart diameter
    static let pieChartHole: CGFloat = 80          // Donut chart inner hole
}

// MARK: - Shadow Styles

enum ShadowStyle {
    static let small = (color: Color.black.opacity(0.05), radius: 4.0, x: 0.0, y: 2.0)
    static let medium = (color: Color.black.opacity(0.08), radius: 8.0, x: 0.0, y: 4.0)
    static let large = (color: Color.black.opacity(0.12), radius: 16.0, x: 0.0, y: 8.0)
}

// MARK: - View Extensions

extension View {
    func vitalCardShadow() -> some View {
        self.shadow(
            color: ShadowStyle.small.color,
            radius: ShadowStyle.small.radius,
            x: ShadowStyle.small.x,
            y: ShadowStyle.small.y
        )
    }

    func vitalElevatedShadow() -> some View {
        self.shadow(
            color: ShadowStyle.medium.color,
            radius: ShadowStyle.medium.radius,
            x: ShadowStyle.medium.x,
            y: ShadowStyle.medium.y
        )
    }

    func vitalFloatingShadow() -> some View {
        self.shadow(
            color: ShadowStyle.large.color,
            radius: ShadowStyle.large.radius,
            x: ShadowStyle.large.x,
            y: ShadowStyle.large.y
        )
    }
}

// MARK: - V2 Premium Spacing System

extension Spacing {
    // MARK: - V2 Corner Radius (Sharper, more technical)

    static let radiusTinyV2: CGFloat = 2
    static let radiusSmallV2: CGFloat = 4
    static let radiusMediumV2: CGFloat = 6
    static let radiusLargeV2: CGFloat = 8
    static let radiusXLargeV2: CGFloat = 12
    static let radiusRoundV2: CGFloat = 9999  // Pill shape
}

// MARK: - V2 Shadow System (Multi-layer with glow)

enum ShadowStyleV2 {
    /// Flat - No shadow, base surface level
    static let flat = (color: Color.clear, radius: 0.0, x: 0.0, y: 0.0)

    /// Raised - Subtle lift for interactive elements
    static let raised = (color: Color.black.opacity(0.12), radius: 4.0, x: 0.0, y: 1.0)

    /// Elevated - Standard card elevation
    static let elevated = (color: Color.black.opacity(0.16), radius: 8.0, x: 0.0, y: 2.0)

    /// Floating - High elevation for modals, popovers
    static let floating = (color: Color.black.opacity(0.24), radius: 16.0, x: 0.0, y: 4.0)

    /// Hero - Maximum elevation for featured content
    static let hero = (color: Color.black.opacity(0.32), radius: 24.0, x: 0.0, y: 8.0)
}

// MARK: - V2 Glow Effects (for dark mode)

enum GlowStyle {
    /// Subtle inner glow for cards
    static let innerGlow = (color: Color.white.opacity(0.05), radius: 1.0, x: 0.0, y: 0.0)

    /// Primary color glow
    static func primaryGlow(intensity: Double = 0.4) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        (color: Color.vitalPrimaryV2.opacity(intensity), radius: 12.0, x: 0.0, y: 0.0)
    }

    /// Accent color glow
    static func accentGlow(intensity: Double = 0.4) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        (color: Color.vitalAccentV2.opacity(intensity), radius: 12.0, x: 0.0, y: 0.0)
    }

    /// Success color glow
    static func successGlow(intensity: Double = 0.4) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        (color: Color.vitalSuccessV2.opacity(intensity), radius: 12.0, x: 0.0, y: 0.0)
    }
}

// MARK: - V2 Shadow View Extensions

extension View {
    /// V2 raised shadow - subtle lift
    func vitalRaisedShadowV2() -> some View {
        self.shadow(
            color: ShadowStyleV2.raised.color,
            radius: ShadowStyleV2.raised.radius,
            x: ShadowStyleV2.raised.x,
            y: ShadowStyleV2.raised.y
        )
    }

    /// V2 elevated shadow - standard card
    func vitalElevatedShadowV2() -> some View {
        self.shadow(
            color: ShadowStyleV2.elevated.color,
            radius: ShadowStyleV2.elevated.radius,
            x: ShadowStyleV2.elevated.x,
            y: ShadowStyleV2.elevated.y
        )
    }

    /// V2 floating shadow - modals, popovers
    func vitalFloatingShadowV2() -> some View {
        self.shadow(
            color: ShadowStyleV2.floating.color,
            radius: ShadowStyleV2.floating.radius,
            x: ShadowStyleV2.floating.x,
            y: ShadowStyleV2.floating.y
        )
    }

    /// V2 hero shadow - featured content
    func vitalHeroShadowV2() -> some View {
        self.shadow(
            color: ShadowStyleV2.hero.color,
            radius: ShadowStyleV2.hero.radius,
            x: ShadowStyleV2.hero.x,
            y: ShadowStyleV2.hero.y
        )
    }

    /// V2 glow effect with custom color
    func vitalGlow(color: Color, radius: CGFloat = 12, intensity: Double = 0.4) -> some View {
        self.shadow(color: color.opacity(intensity), radius: radius, x: 0, y: 0)
    }

    /// V2 primary glow effect
    func vitalPrimaryGlow(intensity: Double = 0.4) -> some View {
        self.shadow(color: Color.vitalPrimaryV2.opacity(intensity), radius: 12, x: 0, y: 0)
    }

    /// V2 accent glow effect
    func vitalAccentGlow(intensity: Double = 0.4) -> some View {
        self.shadow(color: Color.vitalAccentV2.opacity(intensity), radius: 12, x: 0, y: 0)
    }

    /// V2 success glow effect
    func vitalSuccessGlow(intensity: Double = 0.4) -> some View {
        self.shadow(color: Color.vitalSuccessV2.opacity(intensity), radius: 12, x: 0, y: 0)
    }

    /// Multi-layer shadow for depth (dark mode optimized)
    func vitalMultiLayerShadow() -> some View {
        self
            .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    }

    /// Inner glow overlay for cards (1px white at 5% opacity)
    func vitalInnerGlow() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMediumV2)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
