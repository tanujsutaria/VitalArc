//
//  Typography.swift
//  VitalArc
//
//  VitalArc Design System - Typography Scale
//

import SwiftUI

extension Font {
    // MARK: - Display Fonts

    static let vitalDisplayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let vitalDisplayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
    static let vitalDisplaySmall = Font.system(size: 24, weight: .semibold, design: .rounded)

    // MARK: - Headings

    static let vitalH1 = Font.system(size: 22, weight: .bold)
    static let vitalH2 = Font.system(size: 20, weight: .semibold)
    static let vitalH3 = Font.system(size: 18, weight: .semibold)
    static let vitalH4 = Font.system(size: 16, weight: .semibold)

    // MARK: - Body Text

    static let vitalBodyLarge = Font.system(size: 16, weight: .regular)
    static let vitalBody = Font.system(size: 14, weight: .regular)
    static let vitalBodySmall = Font.system(size: 12, weight: .regular)

    // MARK: - Labels

    static let vitalLabel = Font.system(size: 14, weight: .medium)
    static let vitalLabelSmall = Font.system(size: 12, weight: .medium)
    static let vitalLabelTiny = Font.system(size: 10, weight: .medium)

    // MARK: - Caption

    static let vitalCaption = Font.system(size: 12, weight: .regular)
    static let vitalCaptionSmall = Font.system(size: 10, weight: .regular)

    // MARK: - Numbers (Tabular)

    static let vitalNumberLarge = Font.system(size: 28, weight: .bold, design: .rounded).monospacedDigit()
    static let vitalNumberMedium = Font.system(size: 20, weight: .semibold, design: .rounded).monospacedDigit()
    static let vitalNumberSmall = Font.system(size: 16, weight: .medium, design: .rounded).monospacedDigit()

    // MARK: - Icon Fonts (for SF Symbols with text styling)
    // Sizes match Spacing.icon* values for consistent icon sizing

    static let vitalIconTiny = Font.system(size: 10)
    static let vitalIconTinySemibold = Font.system(size: 10, weight: .semibold)
    static let vitalIconXSmall = Font.system(size: 12)
    static let vitalIconXSmallSemibold = Font.system(size: 12, weight: .semibold)
    static let vitalIconSmall = Font.system(size: 16)
    static let vitalIconSmallMedium = Font.system(size: 16, weight: .medium)
    static let vitalIconSmallSemibold = Font.system(size: 16, weight: .semibold)
    static let vitalIconMedium = Font.system(size: 20)
    static let vitalIconMediumMedium = Font.system(size: 20, weight: .medium)
    static let vitalIconMediumSemibold = Font.system(size: 20, weight: .semibold)
    static let vitalIconLarge = Font.system(size: 24)
    static let vitalIconLargeSemibold = Font.system(size: 24, weight: .semibold)
    static let vitalIconXLarge = Font.system(size: 32)
    static let vitalIconXLargeSemibold = Font.system(size: 32, weight: .semibold)
    static let vitalIcon2XLarge = Font.system(size: 40)
    static let vitalIcon2XLargeSemibold = Font.system(size: 40, weight: .semibold)
    static let vitalIconHuge = Font.system(size: 48)
    static let vitalIconHugeSemibold = Font.system(size: 48, weight: .semibold)
    static let vitalIconGiant = Font.system(size: 60)
    static let vitalIconGiantSemibold = Font.system(size: 60, weight: .semibold)
    static let vitalIconHero = Font.system(size: 64)
    static let vitalIconHeroSemibold = Font.system(size: 64, weight: .semibold)
}

// MARK: - Text Styles

extension Text {
    func vitalDisplayStyle() -> some View {
        self.font(.vitalDisplayLarge)
            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
    }

    func vitalHeadlineStyle() -> some View {
        self.font(.vitalH1)
            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
    }

    func vitalBodyStyle() -> some View {
        self.font(.vitalBody)
            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
    }

    func vitalSecondaryStyle() -> some View {
        self.font(.vitalBody)
            .foregroundStyle(Color.vitalAdaptiveTextSecondary)
    }

    func vitalLabelStyle() -> some View {
        self.font(.vitalLabel)
            .foregroundStyle(Color.vitalAdaptiveTextPrimary)
    }
}
