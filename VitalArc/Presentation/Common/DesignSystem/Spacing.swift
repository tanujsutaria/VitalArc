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

    // MARK: - Component Widths

    static let pickerWidthCompact: CGFloat = 150   // Segmented pickers

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
