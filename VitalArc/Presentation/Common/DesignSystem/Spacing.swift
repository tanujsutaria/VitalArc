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

    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 20
    static let iconLarge: CGFloat = 24
    static let iconXLarge: CGFloat = 32

    // MARK: - Border Width

    static let borderThin: CGFloat = 1
    static let borderMedium: CGFloat = 2
    static let borderThick: CGFloat = 3
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
