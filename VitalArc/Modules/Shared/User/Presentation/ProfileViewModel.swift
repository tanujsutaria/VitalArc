//
//  ProfileViewModel.swift
//  VitalArc
//
//  ViewModel for Profile screen
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class ProfileViewModel {
    private let userRepository: UserRepository
    private let healthRepository: HealthRepository?
    private let updatePreferencesUseCase: UpdateUserPreferencesUseCase
    private let calculateTDEEUseCase: CalculateTDEEUseCase?

    // MARK: - State
    var profile: UserProfile?
    var isLoading = false
    var errorMessage: String?
    var isEditMode = false

    // TDEE state
    var tdeeResult: TDEEResult?

    // HealthKit sync state
    var healthKitWeight: Double? // in kg from HealthKit
    var isHealthKitAvailable = false
    var lastHealthKitSync: Date?

    // MARK: - Edit State (stored in American units for display)
    var editName: String = ""
    var editBirthDate: Date = Date()
    var editSex: BiologicalSex = .male
    var editHeightFeet: Int = 5
    var editHeightInches: Int = 10
    var editWeightLbs: Double = 154.0
    var editActivityLevel: ActivityLevel = .moderate
    var editWeightGoal: WeightGoal = .maintain
    var useManualWeight: Bool = false

    // Custom heart rate settings
    var editCustomHRMax: String = "" // Empty string = use estimated
    var editCustomHRResting: String = "" // Empty string = use HealthKit/estimated

    init(
        userRepository: UserRepository,
        healthRepository: HealthRepository? = nil,
        calculateTDEEUseCase: CalculateTDEEUseCase? = nil
    ) {
        self.userRepository = userRepository
        self.healthRepository = healthRepository
        self.calculateTDEEUseCase = calculateTDEEUseCase
        self.updatePreferencesUseCase = UpdateUserPreferencesUseCase(repository: userRepository)
    }

    // MARK: - Profile Operations

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            profile = try await userRepository.getUserProfile()
            if let profile = profile {
                populateEditFields(from: profile)
                loadTDEE(for: profile)
            }

            // Try to sync from HealthKit
            await syncFromHealthKit()

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = UserFacingError.message(for: error, context: .loading)
        }
    }

    func loadTDEE(for profile: UserProfile) {
        guard let useCase = calculateTDEEUseCase else { return }
        tdeeResult = useCase.execute(for: profile)
    }

    func syncFromHealthKit() async {
        guard let healthRepository = healthRepository else { return }

        do {
            // Request authorization if needed
            isHealthKitAvailable = try await healthRepository.requestHealthKitAuthorization()

            if isHealthKitAvailable {
                // Sync latest data
                try await healthRepository.syncFromHealthKit()

                // Get today's metrics (includes weight)
                if let metrics = try await healthRepository.getHealthMetrics(for: Date()) {
                    healthKitWeight = metrics.weight
                    lastHealthKitSync = Date()

                    // Update profile weight if we have HealthKit data and not using manual
                    if let weight = healthKitWeight, !useManualWeight, var currentProfile = profile {
                        currentProfile = UserProfile(
                            id: currentProfile.id,
                            name: currentProfile.name,
                            birthDate: currentProfile.birthDate,
                            biologicalSex: currentProfile.biologicalSex,
                            height: currentProfile.height,
                            weight: weight,
                            activityLevel: currentProfile.activityLevel,
                            weightGoal: currentProfile.weightGoal,
                            customHRMax: currentProfile.customHRMax,
                            customHRResting: currentProfile.customHRResting,
                            createdAt: currentProfile.createdAt,
                            updatedAt: Date()
                        )
                        try await userRepository.updateUserProfile(currentProfile)
                        profile = currentProfile
                        editWeightLbs = UnitConversion.kgToLbs(weight)
                    }
                }
            }
        } catch {
            // HealthKit sync failed silently - user can still use manual entry
            Log.error("HealthKit sync failed", error: error, category: .healthKit)
        }
    }

    func startEditing() {
        guard let profile = profile else { return }
        populateEditFields(from: profile)
        isEditMode = true
    }

    func cancelEditing() {
        isEditMode = false
        errorMessage = nil
    }

    func saveProfile() async {
        guard let currentProfile = profile else { return }

        isLoading = true
        errorMessage = nil

        do {
            // Convert American units back to metric for storage
            let heightCm = UnitConversion.feetInchesToCm(feet: editHeightFeet, inches: editHeightInches)
            let weightKg = UnitConversion.lbsToKg(editWeightLbs)

            // Parse custom HR values (empty string = nil = use estimated)
            let customHRMax = Int(editCustomHRMax)
            let customHRResting = Int(editCustomHRResting)

            let updatedProfile = UserProfile(
                id: currentProfile.id,
                name: editName.trimmingCharacters(in: .whitespaces),
                birthDate: editBirthDate,
                biologicalSex: editSex,
                height: heightCm,
                weight: weightKg,
                activityLevel: editActivityLevel,
                weightGoal: editWeightGoal,
                customHRMax: customHRMax,
                customHRResting: customHRResting,
                createdAt: currentProfile.createdAt,
                updatedAt: Date()
            )

            try await updatePreferencesUseCase.execute(profile: updatedProfile)
            profile = updatedProfile
            isEditMode = false
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = UserFacingError.message(for: error, context: .saving)
        }
    }

    // MARK: - Helpers

    private func populateEditFields(from profile: UserProfile) {
        editName = profile.name
        editBirthDate = profile.birthDate
        editSex = profile.biologicalSex

        // Convert metric to American units
        let (feet, inches) = UnitConversion.cmToFeetInches(profile.height)
        editHeightFeet = feet
        editHeightInches = inches
        editWeightLbs = UnitConversion.kgToLbs(profile.weight)

        editActivityLevel = profile.activityLevel
        editWeightGoal = profile.weightGoal

        // Custom HR values (convert Int? to String for text field)
        editCustomHRMax = profile.customHRMax.map { String($0) } ?? ""
        editCustomHRResting = profile.customHRResting.map { String($0) } ?? ""
    }

    var canSave: Bool {
        !editName.trimmingCharacters(in: .whitespaces).isEmpty &&
        editHeightFeet > 0 &&
        editWeightLbs > 0
    }

    // Display helpers
    var displayWeight: String {
        if let profile = profile {
            return String(format: "%.1f lbs", UnitConversion.kgToLbs(profile.weight))
        }
        return "-"
    }

    var displayHeight: String {
        if let profile = profile {
            let (feet, inches) = UnitConversion.cmToFeetInches(profile.height)
            return "\(feet)'\(inches)\""
        }
        return "-"
    }

    var weightSource: String {
        if healthKitWeight != nil && !useManualWeight {
            return "from Apple Health"
        }
        return "manual entry"
    }

    // Heart rate display helpers
    var displayHRMax: String {
        guard let profile = profile else { return "-" }
        if let custom = profile.customHRMax {
            return "\(custom) bpm (custom)"
        }
        return "\(profile.estimatedHRMax) bpm (estimated)"
    }

    var displayHRResting: String {
        guard let profile = profile else { return "-" }
        if let custom = profile.customHRResting {
            return "\(custom) bpm (custom)"
        }
        return "\(profile.estimatedHRResting) bpm (default)"
    }
}

// MARK: - Unit Conversion Helpers

enum UnitConversion {
    // Weight conversions
    static func kgToLbs(_ kg: Double) -> Double {
        return kg * 2.20462
    }

    static func lbsToKg(_ lbs: Double) -> Double {
        return lbs / 2.20462
    }

    // Height conversions
    static func cmToFeetInches(_ cm: Double) -> (feet: Int, inches: Int) {
        let totalInches = cm / 2.54
        let feet = Int(totalInches) / 12
        let inches = Int(totalInches.rounded()) % 12
        return (feet, inches)
    }

    static func feetInchesToCm(feet: Int, inches: Int) -> Double {
        let totalInches = Double(feet * 12 + inches)
        return totalInches * 2.54
    }
}
