//
//  BodyCompositionViewModel.swift
//  VitalArc
//
//  ViewModel for body composition tracking
//

import Foundation
import Observation

@MainActor
@Observable
final class BodyCompositionViewModel {
    // MARK: - Published State

    var measurements: [BodyCompositionEntry] = []
    var latestMeasurement: BodyCompositionEntry?
    var isLoading = false
    var error: Error?
    var showingAddForm = false
    var useImperial = true

    // MARK: - Add Form State

    var formWeight: String = ""
    var formBodyFat: String = ""
    var formWaist: String = ""
    var formHip: String = ""
    var formChest: String = ""
    var formArm: String = ""
    var formThigh: String = ""
    var formNeck: String = ""
    var formNotes: String = ""

    // MARK: - Chart Time Range

    var chartMonths: Int = 3

    // MARK: - Dependencies

    private let saveUseCase: SaveBodyCompositionEntryUseCaseProtocol
    private let getUseCase: GetBodyCompositionEntriesUseCaseProtocol
    private let repository: BodyCompositionEntryRepository

    init(
        saveUseCase: SaveBodyCompositionEntryUseCaseProtocol,
        getUseCase: GetBodyCompositionEntriesUseCaseProtocol,
        repository: BodyCompositionEntryRepository
    ) {
        self.saveUseCase = saveUseCase
        self.getUseCase = getUseCase
        self.repository = repository
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -chartMonths, to: endDate) ?? endDate

            measurements = try await getUseCase.execute(from: startDate, to: endDate)
            latestMeasurement = try await getUseCase.getLatest()
        } catch {
            self.error = error
            Log.error("Failed to load body measurements", error: error, category: .nutrition)
        }
    }

    // MARK: - Save Measurement

    func saveMeasurement() async {
        let weight: Double? = {
            guard let val = Double(formWeight), val > 0 else { return nil }
            return useImperial ? UnitConversion.lbsToKg(val) : val
        }()

        let bodyFat: Double? = {
            guard let val = Double(formBodyFat), val > 0, val <= 100 else { return nil }
            return val
        }()

        let parseCm: (String) -> Double? = { [useImperial] str in
            guard let val = Double(str), val > 0 else { return nil }
            return useImperial ? val * 2.54 : val  // inches to cm
        }

        let measurement = BodyCompositionEntry(
            date: Date(),
            weight: weight,
            bodyFatPercentage: bodyFat,
            waistCircumference: parseCm(formWaist),
            hipCircumference: parseCm(formHip),
            chestCircumference: parseCm(formChest),
            armCircumference: parseCm(formArm),
            thighCircumference: parseCm(formThigh),
            neckCircumference: parseCm(formNeck),
            notes: formNotes.isEmpty ? nil : formNotes
        )

        do {
            try await saveUseCase.execute(measurement)
            clearForm()
            showingAddForm = false
            await loadData()
        } catch {
            self.error = error
            Log.error("Failed to save body measurement", error: error, category: .nutrition)
        }
    }

    // MARK: - Delete Measurement

    func deleteMeasurement(_ id: UUID) async {
        do {
            try await repository.deleteMeasurement(id)
            await loadData()
        } catch {
            self.error = error
            Log.error("Failed to delete body measurement", error: error, category: .nutrition)
        }
    }

    // MARK: - Form Helpers

    func clearForm() {
        formWeight = ""
        formBodyFat = ""
        formWaist = ""
        formHip = ""
        formChest = ""
        formArm = ""
        formThigh = ""
        formNeck = ""
        formNotes = ""
    }

    /// Pre-fill form with latest measurement for easy updates
    func prefillFromLatest() {
        guard let latest = latestMeasurement else { return }

        if let w = latest.weight {
            formWeight = String(format: "%.1f", useImperial ? UnitConversion.kgToLbs(w) : w)
        }
        if let bf = latest.bodyFatPercentage {
            formBodyFat = String(format: "%.1f", bf)
        }

        let formatCm: (Double?) -> String = { [useImperial] val in
            guard let val = val else { return "" }
            return String(format: "%.1f", useImperial ? val / 2.54 : val)
        }

        formWaist = formatCm(latest.waistCircumference)
        formHip = formatCm(latest.hipCircumference)
        formChest = formatCm(latest.chestCircumference)
        formArm = formatCm(latest.armCircumference)
        formThigh = formatCm(latest.thighCircumference)
        formNeck = formatCm(latest.neckCircumference)
    }

    // MARK: - Display Helpers

    func displayWeight(_ kg: Double) -> String {
        if useImperial {
            return String(format: "%.1f lbs", UnitConversion.kgToLbs(kg))
        }
        return String(format: "%.1f kg", kg)
    }

    func displayCircumference(_ cm: Double) -> String {
        if useImperial {
            return String(format: "%.1f in", cm / 2.54)
        }
        return String(format: "%.1f cm", cm)
    }

    var weightUnit: String { useImperial ? "lbs" : "kg" }
    var circumferenceUnit: String { useImperial ? "in" : "cm" }

    // MARK: - Trend Data

    var weightTrend: [(date: Date, value: Double)] {
        measurements.compactMap { m in
            guard let w = m.weight else { return nil }
            return (date: m.date, value: useImperial ? UnitConversion.kgToLbs(w) : w)
        }.sorted { $0.date < $1.date }
    }

    var bodyFatTrend: [(date: Date, value: Double)] {
        measurements.compactMap { m in
            guard let bf = m.bodyFatPercentage else { return nil }
            return (date: m.date, value: bf)
        }.sorted { $0.date < $1.date }
    }

    var waistToHipTrend: [(date: Date, value: Double)] {
        measurements.compactMap { m in
            guard let whr = m.waistToHipRatio else { return nil }
            return (date: m.date, value: whr)
        }.sorted { $0.date < $1.date }
    }

    /// Whether the form has at least one measurement field filled
    var hasFormData: Bool {
        !formWeight.isEmpty || !formBodyFat.isEmpty || !formWaist.isEmpty ||
        !formHip.isEmpty || !formChest.isEmpty || !formArm.isEmpty ||
        !formThigh.isEmpty || !formNeck.isEmpty
    }
}
