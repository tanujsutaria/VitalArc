//
//  PlateCalculatorViewModel.swift
//  VitalArc
//
//  ViewModel for the plate calculator utility
//

import Foundation
import Observation

@MainActor
@Observable
final class PlateCalculatorViewModel {
    // Available plate sizes in kg (standard Olympic plates)
    static let availablePlatesKg: [Double] = [25, 20, 15, 10, 5, 2.5, 1.25]

    // Common bar weights
    static let standardBarWeightKg: Double = 20
    static let standardBarWeightLbs: Double = 45

    var targetWeight: Double = 60  // in kg
    var barWeight: Double = standardBarWeightKg
    var useImperial: Bool = false

    /// Plates to load per side
    var platesPerSide: [Double] {
        calculatePlates(
            targetWeight: useImperial ? UnitConversion.lbsToKg(targetWeight) : targetWeight,
            barWeight: useImperial ? UnitConversion.lbsToKg(barWeight) : barWeight
        )
    }

    /// Whether the target weight is achievable
    var isAchievable: Bool {
        let target = useImperial ? UnitConversion.lbsToKg(targetWeight) : targetWeight
        let bar = useImperial ? UnitConversion.lbsToKg(barWeight) : barWeight
        let perSide = (target - bar) / 2.0
        if perSide < 0 { return false }
        let achieved = calculatePlates(targetWeight: target, barWeight: bar).reduce(0, +)
        return abs(achieved - perSide) < 0.01
    }

    /// Actual weight that will be loaded (may differ if unachievable)
    var actualWeight: Double {
        let bar = useImperial ? UnitConversion.lbsToKg(barWeight) : barWeight
        let totalPlates = platesPerSide.reduce(0, +) * 2
        let totalKg = bar + totalPlates
        return useImperial ? UnitConversion.kgToLbs(totalKg) : totalKg
    }

    /// Weight per side
    var weightPerSide: Double {
        let perSideKg = platesPerSide.reduce(0, +)
        return useImperial ? UnitConversion.kgToLbs(perSideKg) : perSideKg
    }

    var weightUnit: String {
        useImperial ? "lbs" : "kg"
    }

    // MARK: - Plate Calculation (greedy algorithm)

    /// Returns array of plate weights per side (in kg) using greedy approach
    static func calculatePlatesPerSide(targetWeight: Double, barWeight: Double, availablePlates: [Double] = availablePlatesKg) -> [Double] {
        let perSide = (targetWeight - barWeight) / 2.0
        guard perSide > 0 else { return [] }

        var remaining = perSide
        var plates: [Double] = []

        for plate in availablePlates.sorted(by: >) {
            while remaining >= plate - 0.001 {
                plates.append(plate)
                remaining -= plate
            }
        }

        return plates
    }

    private func calculatePlates(targetWeight: Double, barWeight: Double) -> [Double] {
        Self.calculatePlatesPerSide(targetWeight: targetWeight, barWeight: barWeight)
    }

    // MARK: - Plate Colors

    /// Standard color mapping for Olympic plates
    static func plateColor(weightKg: Double) -> PlateColor {
        switch weightKg {
        case 25: return .red
        case 20: return .blue
        case 15: return .yellow
        case 10: return .green
        case 5: return .white
        case 2.5: return .black
        case 1.25: return .silver
        default: return .gray
        }
    }

    enum PlateColor: String {
        case red, blue, yellow, green, white, black, silver, gray
    }

    // MARK: - Presets

    func setPreset(targetKg: Double) {
        useImperial = false
        targetWeight = targetKg
        barWeight = Self.standardBarWeightKg
    }

    func toggleUnits() {
        if useImperial {
            // Switch to metric
            targetWeight = UnitConversion.lbsToKg(targetWeight)
            barWeight = UnitConversion.lbsToKg(barWeight)
            useImperial = false
        } else {
            // Switch to imperial
            targetWeight = UnitConversion.kgToLbs(targetWeight)
            barWeight = UnitConversion.kgToLbs(barWeight)
            useImperial = true
        }
    }
}
