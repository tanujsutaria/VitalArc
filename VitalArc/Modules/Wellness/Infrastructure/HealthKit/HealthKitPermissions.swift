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

    /// Check if all required permissions are granted
    static func hasRequiredAuthorization(healthStore: HKHealthStore) -> Bool {
        let readTypes = requiredReadTypes()
        return readTypes.allSatisfy { type in
            let status = healthStore.authorizationStatus(for: type)
            return status == .sharingAuthorized
        }
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

        // Note: Due to privacy, we can't definitively determine if user granted access
        // We can only check if the request was processed
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
