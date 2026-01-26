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
