//
//  HealthKitPermissions.swift
//  VitalArc
//
//  Manages HealthKit authorization
//

import Foundation
import HealthKit

/// Manages HealthKit permissions and authorization
struct HealthKitPermissions {

    // MARK: - Required Types

    /// Returns all HealthKit types that need read permission
    static func requiredReadTypes() -> Set<HKObjectType> {
        var types: Set<HKObjectType> = []

        // Heart metrics
        if let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(hrvType)
        }
        if let restingHRType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(restingHRType)
        }
        if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) {
            types.insert(heartRateType)
        }

        // Activity metrics
        if let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(activeEnergyType)
        }
        if let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepsType)
        }

        // Sleep
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepType)
        }

        // Body measurements
        if let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) {
            types.insert(weightType)
        }
        if let bodyFatType = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage) {
            types.insert(bodyFatType)
        }
        if let leanBodyMassType = HKObjectType.quantityType(forIdentifier: .leanBodyMass) {
            types.insert(leanBodyMassType)
        }

        // Respiratory
        if let respiratoryRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate) {
            types.insert(respiratoryRateType)
        }

        return types
    }

    /// Returns all HealthKit types that need write permission (currently none)
    static func requiredWriteTypes() -> Set<HKSampleType> {
        return []
    }

    // MARK: - Authorization Status

    /// Check authorization status for a specific type
    static func authorizationStatus(for type: HKObjectType, healthStore: HKHealthStore) -> HKAuthorizationStatus {
        return healthStore.authorizationStatus(for: type)
    }

    /// Check if HealthKit authorization has been requested.
    ///
    /// **Apple Privacy Limitation**: `HKHealthStore.authorizationStatus(for:)` only
    /// reports status for **write** types. For read-only types it always returns
    /// `.notDetermined`, even after the user grants or revokes access in
    /// Settings → Privacy → Health. We therefore track whether the authorization
    /// dialog was presented via UserDefaults.
    ///
    /// This flag can become stale if the user revokes access after granting it.
    /// Callers that depend on actual data availability (e.g., `syncFromHealthKit`)
    /// should handle empty results gracefully and call `clearAuthorizationFlag()`
    /// when a sync returns no data, prompting re-authorization on next use.
    static func hasRequiredAuthorization(healthStore: HKHealthStore) -> Bool {
        return UserDefaults.standard.bool(forKey: "healthKitAuthorizationRequested")
    }

    /// Clear the authorization-requested flag, forcing re-authorization on next sync.
    /// Call this when a sync returns no data, suggesting the user may have revoked access.
    static func clearAuthorizationFlag() {
        UserDefaults.standard.removeObject(forKey: "healthKitAuthorizationRequested")
    }

    /// Check if HealthKit is available on this device
    static func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Request Authorization

    /// Request authorization for all required types
    static func requestAuthorization(
        healthStore: HKHealthStore
    ) async throws -> Bool {
        guard isHealthKitAvailable() else {
            throw HealthKitError.notAvailable
        }

        let readTypes = requiredReadTypes()
        let writeTypes = requiredWriteTypes()

        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)

        // Track that authorization was requested (read status is private per Apple policy)
        UserDefaults.standard.set(true, forKey: "healthKitAuthorizationRequested")
        return true
    }
}

// MARK: - Errors

public enum HealthKitError: LocalizedError {
    case notAvailable
    case unauthorized
    case queryFailed
    case noData

    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .unauthorized:
            return "HealthKit access not authorized"
        case .queryFailed:
            return "Failed to query HealthKit data"
        case .noData:
            return "No HealthKit data available"
        }
    }
}
