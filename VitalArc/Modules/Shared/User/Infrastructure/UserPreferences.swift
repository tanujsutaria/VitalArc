//
//  UserPreferences.swift
//  VitalArc
//
//  Centralized user preferences with unit formatting helpers
//

import SwiftUI

/// Centralized user preferences using @AppStorage for persistence.
/// Provides consistent unit formatting across the app.
enum UserPreferences {
    /// Whether to use metric units (kg, cm) or American units (lbs, ft/in).
    /// Default is false (American units) per app convention.
    @AppStorage("useMetricUnits") static var useMetricUnits: Bool = false

    // MARK: - Unit Labels

    /// The appropriate weight unit label based on user preference
    static var weightUnit: String {
        useMetricUnits ? "kg" : "lbs"
    }

    /// The appropriate height unit label based on user preference
    static var heightUnit: String {
        useMetricUnits ? "cm" : "ft"
    }

    // MARK: - Formatting Helpers

    /// Formats a weight value (stored in kg) for display according to user preference.
    /// - Parameter kg: Weight in kilograms
    /// - Returns: Formatted string with unit (e.g., "70.5 kg" or "155.4 lbs")
    static func formatWeight(_ kg: Double) -> String {
        if useMetricUnits {
            return String(format: "%.1f kg", kg)
        } else {
            return String(format: "%.1f lbs", UnitConversion.kgToLbs(kg))
        }
    }

    /// Formats a height value (stored in cm) for display according to user preference.
    /// - Parameter cm: Height in centimeters
    /// - Returns: Formatted string with unit (e.g., "175 cm" or "5'9\"")
    static func formatHeight(_ cm: Double) -> String {
        if useMetricUnits {
            return String(format: "%.0f cm", cm)
        } else {
            let (ft, inches) = UnitConversion.cmToFeetInches(cm)
            return "\(ft)'\(inches)\""
        }
    }

    /// Formats a weight value with just the number (no unit suffix).
    /// Useful when the unit is displayed separately.
    /// - Parameter kg: Weight in kilograms
    /// - Returns: Formatted number string (e.g., "70.5" or "155.4")
    static func formatWeightValue(_ kg: Double) -> String {
        if useMetricUnits {
            return String(format: "%.1f", kg)
        } else {
            return String(format: "%.1f", UnitConversion.kgToLbs(kg))
        }
    }

    /// Converts a display weight value to kg for storage.
    /// - Parameter displayValue: Weight in user's preferred unit
    /// - Returns: Weight in kilograms
    static func displayWeightToKg(_ displayValue: Double) -> Double {
        if useMetricUnits {
            return displayValue
        } else {
            return UnitConversion.lbsToKg(displayValue)
        }
    }

    /// Converts kg to the user's preferred display unit.
    /// - Parameter kg: Weight in kilograms
    /// - Returns: Weight in user's preferred unit
    static func kgToDisplayWeight(_ kg: Double) -> Double {
        if useMetricUnits {
            return kg
        } else {
            return UnitConversion.kgToLbs(kg)
        }
    }
}
