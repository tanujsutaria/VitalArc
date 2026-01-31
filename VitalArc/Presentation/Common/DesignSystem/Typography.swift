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

// MARK: - V2 Premium Typography System

extension Font {
    // MARK: - Custom Font Names

    private static let interRegular = "Inter-Regular"
    private static let interMedium = "Inter-Medium"
    private static let interSemiBold = "Inter-SemiBold"
    private static let interBold = "Inter-Bold"

    private static let jetBrainsMedium = "JetBrainsMono-Medium"
    private static let jetBrainsSemiBold = "JetBrainsMono-SemiBold"
    private static let jetBrainsBold = "JetBrainsMono-Bold"

    // MARK: - Custom Font Helper (with fallback)

    /// Creates a custom font with fallback to system font
    private static func customFont(_ name: String, size: CGFloat, weight: Font.Weight) -> Font {
        if UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size)
        } else {
            // Fallback to SF Pro
            return Font.system(size: size, weight: weight)
        }
    }

    // MARK: - V2 Display Fonts (Inter Bold, no rounded design)

    static let vitalDisplayLargeV2 = customFont(interBold, size: 34, weight: .bold)
    static let vitalDisplayMediumV2 = customFont(interBold, size: 28, weight: .bold)
    static let vitalDisplaySmallV2 = customFont(interSemiBold, size: 24, weight: .semibold)

    // MARK: - V2 Headings (Inter)

    static let vitalH1V2 = customFont(interBold, size: 22, weight: .bold)
    static let vitalH2V2 = customFont(interSemiBold, size: 20, weight: .semibold)
    static let vitalH3V2 = customFont(interSemiBold, size: 18, weight: .semibold)
    static let vitalH4V2 = customFont(interSemiBold, size: 16, weight: .semibold)

    // MARK: - V2 Body Text (Inter)

    static let vitalBodyLargeV2 = customFont(interRegular, size: 16, weight: .regular)
    static let vitalBodyV2 = customFont(interRegular, size: 14, weight: .regular)
    static let vitalBodySmallV2 = customFont(interRegular, size: 12, weight: .regular)

    // MARK: - V2 Labels (Inter Medium)

    static let vitalLabelV2 = customFont(interMedium, size: 14, weight: .medium)
    static let vitalLabelSmallV2 = customFont(interMedium, size: 12, weight: .medium)
    static let vitalLabelTinyV2 = customFont(interMedium, size: 10, weight: .medium)

    // MARK: - V2 Captions (Inter Regular)

    static let vitalCaptionV2 = customFont(interRegular, size: 12, weight: .regular)
    static let vitalCaptionSmallV2 = customFont(interRegular, size: 10, weight: .regular)

    // MARK: - V2 Numbers (JetBrains Mono - Technical, Tabular)

    static let vitalNumberHeroV2 = customFont(jetBrainsBold, size: 48, weight: .bold)
    static let vitalNumberXLargeV2 = customFont(jetBrainsBold, size: 36, weight: .bold)
    static let vitalNumberLargeV2 = customFont(jetBrainsBold, size: 28, weight: .bold)
    static let vitalNumberMediumV2 = customFont(jetBrainsSemiBold, size: 20, weight: .semibold)
    static let vitalNumberSmallV2 = customFont(jetBrainsMedium, size: 16, weight: .medium)
    static let vitalNumberTinyV2 = customFont(jetBrainsMedium, size: 12, weight: .medium)

    // MARK: - V2 Data Display (JetBrains Mono for metrics/stats)

    static let vitalDataLargeV2 = customFont(jetBrainsSemiBold, size: 24, weight: .semibold)
    static let vitalDataMediumV2 = customFont(jetBrainsMedium, size: 18, weight: .medium)
    static let vitalDataSmallV2 = customFont(jetBrainsMedium, size: 14, weight: .medium)

    // MARK: - V2 Unit Labels (smaller JetBrains for units like "kg", "bpm")

    static let vitalUnitV2 = customFont(jetBrainsMedium, size: 11, weight: .medium)
    static let vitalUnitSmallV2 = customFont(jetBrainsMedium, size: 9, weight: .medium)
}

// MARK: - V2 Text Styles

extension Text {
    func vitalDisplayStyleV2() -> some View {
        self.font(.vitalDisplayLargeV2)
            .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
    }

    func vitalHeadlineStyleV2() -> some View {
        self.font(.vitalH1V2)
            .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
    }

    func vitalBodyStyleV2() -> some View {
        self.font(.vitalBodyV2)
            .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
    }

    func vitalSecondaryStyleV2() -> some View {
        self.font(.vitalBodyV2)
            .foregroundStyle(Color.vitalAdaptiveTextSecondaryV2)
    }

    func vitalLabelStyleV2() -> some View {
        self.font(.vitalLabelV2)
            .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
    }

    func vitalDataStyleV2() -> some View {
        self.font(.vitalDataMediumV2)
            .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
    }

    func vitalNumberStyleV2() -> some View {
        self.font(.vitalNumberLargeV2)
            .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)
    }
}

// MARK: - Font Availability Check

enum VitalFonts {
    /// Check if custom fonts are available
    static var isInterAvailable: Bool {
        UIFont(name: "Inter-Regular", size: 14) != nil
    }

    static var isJetBrainsMonoAvailable: Bool {
        UIFont(name: "JetBrainsMono-Medium", size: 14) != nil
    }

    static var areCustomFontsAvailable: Bool {
        isInterAvailable && isJetBrainsMonoAvailable
    }

    /// Debug: Print all available font families
    static func printAvailableFonts() {
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  - \(name)")
            }
        }
    }
}
