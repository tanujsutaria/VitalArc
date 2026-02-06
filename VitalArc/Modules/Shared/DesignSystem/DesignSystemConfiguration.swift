//
//  DesignSystemConfiguration.swift
//  VitalArc
//
//  Design System Configuration for V1/V2 Theme Switching
//

import SwiftUI

// MARK: - Design System Version

/// Represents the design system version in use
enum DesignSystemVersion: String, CaseIterable {
    /// Original VitalArc design (indigo-based, rounded corners)
    case v1 = "Classic"

    /// Premium WHOOP-inspired design (strain red, technical, sharp)
    case v2 = "Premium"
}

// MARK: - Design System Configuration

/// Centralized configuration for the VitalArc design system
/// Allows gradual migration from V1 to V2 design
@Observable
final class DesignSystemConfiguration {
    /// Current design system version
    var version: DesignSystemVersion

    /// Whether to use the premium (V2) color palette
    var usePremiumColors: Bool { version == .v2 }

    /// Whether to use custom fonts (Inter, JetBrains Mono)
    var useCustomFonts: Bool { version == .v2 && VitalFonts.areCustomFontsAvailable }

    /// Whether to use sharper corner radii
    var useSharpCorners: Bool { version == .v2 }

    /// Whether to use enhanced shadow/glow effects
    var useEnhancedShadows: Bool { version == .v2 }

    init(version: DesignSystemVersion = .v2) {
        self.version = version
    }

    // MARK: - Semantic Color Accessors

    var primaryColor: Color {
        version == .v2 ? .vitalPrimaryV2 : .vitalPrimary
    }

    var secondaryColor: Color {
        version == .v2 ? .vitalSecondaryV2 : .vitalSecondary
    }

    var accentColor: Color {
        version == .v2 ? .vitalAccentV2 : .vitalAccent
    }

    var successColor: Color {
        version == .v2 ? .vitalSuccessV2 : .vitalSuccess
    }

    var dangerColor: Color {
        version == .v2 ? .vitalDangerV2 : .vitalDanger
    }

    var warningColor: Color {
        version == .v2 ? .vitalWarningV2 : .vitalWarning
    }

    var backgroundColor: Color {
        version == .v2 ? .vitalAdaptiveBackgroundV2 : .vitalAdaptiveBackground
    }

    var surfaceColor: Color {
        version == .v2 ? .vitalAdaptiveSurfaceV2 : .vitalAdaptiveSurface
    }

    var borderColor: Color {
        version == .v2 ? .vitalAdaptiveBorderV2 : .vitalAdaptiveBorder
    }

    var textPrimaryColor: Color {
        version == .v2 ? .vitalAdaptiveTextPrimaryV2 : .vitalAdaptiveTextPrimary
    }

    var textSecondaryColor: Color {
        version == .v2 ? .vitalAdaptiveTextSecondaryV2 : .vitalAdaptiveTextSecondary
    }

    // MARK: - Semantic Spacing Accessors

    var radiusSmall: CGFloat {
        version == .v2 ? Spacing.radiusSmallV2 : Spacing.radiusSmall
    }

    var radiusMedium: CGFloat {
        version == .v2 ? Spacing.radiusMediumV2 : Spacing.radiusMedium
    }

    var radiusLarge: CGFloat {
        version == .v2 ? Spacing.radiusLargeV2 : Spacing.radiusLarge
    }

    // MARK: - Semantic Font Accessors

    var displayLargeFont: Font {
        version == .v2 ? .vitalDisplayLargeV2 : .vitalDisplayLarge
    }

    var h1Font: Font {
        version == .v2 ? .vitalH1V2 : .vitalH1
    }

    var h2Font: Font {
        version == .v2 ? .vitalH2V2 : .vitalH2
    }

    var h3Font: Font {
        version == .v2 ? .vitalH3V2 : .vitalH3
    }

    var bodyFont: Font {
        version == .v2 ? .vitalBodyV2 : .vitalBody
    }

    var labelFont: Font {
        version == .v2 ? .vitalLabelV2 : .vitalLabel
    }

    var numberLargeFont: Font {
        version == .v2 ? .vitalNumberLargeV2 : .vitalNumberLarge
    }

    // MARK: - Primary Gradient

    var primaryGradient: LinearGradient {
        version == .v2 ? Color.vitalPrimaryGradientV2 : Color.vitalPrimaryGradient
    }
}

// MARK: - Environment Key

private struct DesignSystemConfigurationKey: EnvironmentKey {
    static let defaultValue = DesignSystemConfiguration()
}

extension EnvironmentValues {
    var designSystem: DesignSystemConfiguration {
        get { self[DesignSystemConfigurationKey.self] }
        set { self[DesignSystemConfigurationKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Access

extension View {
    /// Apply the design system configuration to the view hierarchy
    func designSystemConfiguration(_ configuration: DesignSystemConfiguration) -> some View {
        self.environment(\.designSystem, configuration)
    }

    /// Apply V2 (Premium) design system
    func premiumDesign() -> some View {
        self.environment(\.designSystem, DesignSystemConfiguration(version: .v2))
    }

    /// Apply V1 (Classic) design system
    func classicDesign() -> some View {
        self.environment(\.designSystem, DesignSystemConfiguration(version: .v1))
    }
}

// MARK: - Preview Helper

#Preview("Design System Comparison") {
    VStack(spacing: Spacing.lg) {
        // V1 Preview
        VStack(spacing: Spacing.md) {
            Text("V1 Classic Design")
                .font(.vitalH2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimary)

            RoundedRectangle(cornerRadius: Spacing.radiusLarge)
                .fill(Color.vitalPrimary)
                .frame(height: 60)
                .overlay(
                    Text("Primary Button")
                        .font(.vitalLabel)
                        .foregroundStyle(.white)
                )
        }
        .padding()
        .background(Color.vitalAdaptiveSurface)
        .cornerRadius(Spacing.radiusLarge)

        // V2 Preview
        VStack(spacing: Spacing.md) {
            Text("V2 Premium Design")
                .font(.vitalH2V2)
                .foregroundStyle(Color.vitalAdaptiveTextPrimaryV2)

            RoundedRectangle(cornerRadius: Spacing.radiusLargeV2)
                .fill(Color.vitalPrimaryV2)
                .frame(height: 60)
                .overlay(
                    Text("Primary Button")
                        .font(.vitalLabelV2)
                        .foregroundStyle(.white)
                )
                .vitalPrimaryGlow(intensity: 0.3)
        }
        .padding()
        .background(Color.vitalAdaptiveSurfaceV2)
        .cornerRadius(Spacing.radiusLargeV2)
        .vitalInnerGlow()
    }
    .padding()
    .background(Color.vitalAdaptiveBackgroundV2)
}
