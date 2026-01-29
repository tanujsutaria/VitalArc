//
//  CalculateStrainScoreUseCase.swift
//  VitalArc
//
//  Calculates training strain using TRIMP (Training Impulse) methodology
//  Based on Banister (1991) exponential TRIMP and Edwards (1993) zone-based TRIMP
//

import Foundation

/// Workout data with heart rate information
struct WorkoutData: Equatable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let workoutType: String?
    let averageHeartRate: Double?
    let heartRateSamples: [HeartRateSample]

    var hasHeartRateData: Bool {
        averageHeartRate != nil || !heartRateSamples.isEmpty
    }
}

/// Individual heart rate sample during a workout
struct HeartRateSample: Equatable {
    let timestamp: Date
    let bpm: Double
}

@MainActor
final class CalculateStrainScoreUseCase {
    private let healthRepository: HealthRepository
    private let userRepository: UserRepository

    /// Scaling factor for converting raw TRIMP to 0-21 strain score
    /// Based on typical TRIMP values: 50-300 TRIMP = 0-21 strain
    private let trimpToStrainScaleFactor: Double = 21.0 / 250.0

    init(healthRepository: HealthRepository, userRepository: UserRepository) {
        self.healthRepository = healthRepository
        self.userRepository = userRepository
    }

    // MARK: - Public Interface

    /// Calculate strain score for today
    func executeDailyStrain() async throws -> Double {
        let today = Date()
        guard let result = try await execute(for: today) else {
            return 0
        }
        return result.strainScore
    }

    /// Calculate strain score for a specific date
    func execute(for date: Date) async throws -> StrainResult? {
        // For now, return estimated strain based on workout count
        // Full implementation requires HealthKit workout queries
        let (hrMax, hrRest) = try await getHeartRateParameters()

        // Estimate based on typical workout duration
        let estimatedDuration: TimeInterval = 60 * 60 // 1 hour
        let estimatedTrimp = estimateTRIMPFromDuration(estimatedDuration)
        let strainScore = min(estimatedTrimp * trimpToStrainScaleFactor, 21.0)

        return StrainResult(
            date: date,
            trimpScore: estimatedTrimp,
            strainScore: strainScore,
            duration: estimatedDuration,
            averageHeartRate: nil,
            maxHeartRate: nil,
            heartRateReserve: nil,
            workoutCount: 1,
            calculationMethod: .estimated
        )
    }

    /// Calculate strain scores for a date range
    func executeForDateRange(from startDate: Date, to endDate: Date) async throws -> [StrainResult] {
        let calendar = Calendar.current
        var results: [StrainResult] = []
        var currentDate = startDate

        while currentDate <= endDate {
            if let result = try await execute(for: currentDate) {
                results.append(result)
            }

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return results
    }

    // MARK: - TRIMP Calculations

    /// Banister TRIMP (1991) - Exponential method
    /// TRIMP = sum(D * HRr * 0.64 * e^(k * HRr))
    /// where k = 1.92 for males, 1.67 for females
    func calculateBanisterTRIMP(
        samples: [HeartRateSample],
        duration: TimeInterval,
        hrMax: Double,
        hrRest: Double
    ) -> Double {
        guard !samples.isEmpty else { return 0 }

        let exponentialFactor = 1.92 // Male default
        let hrReserve = hrMax - hrRest
        guard hrReserve > 0 else { return 0 }

        var totalTrimp: Double = 0
        let timePerSample = duration / Double(samples.count)
        let minutesPerSample = timePerSample / 60.0

        for sample in samples {
            let hrr = (sample.bpm - hrRest) / hrReserve
            let hrrClamped = max(0, min(hrr, 1.0))
            let sampleTrimp = minutesPerSample * hrrClamped * 0.64 * exp(exponentialFactor * hrrClamped)
            totalTrimp += sampleTrimp
        }

        return totalTrimp
    }

    /// Edwards TRIMP (1993) - Zone-based method
    func calculateEdwardsTRIMP(
        averageHR: Double,
        duration: TimeInterval,
        hrMax: Double
    ) -> Double {
        let minutes = duration / 60.0
        let percentHRMax = (averageHR / hrMax) * 100

        let zoneMultiplier: Double
        switch percentHRMax {
        case 0..<50:
            zoneMultiplier = 1.0
        case 50..<60:
            zoneMultiplier = 1.0
        case 60..<70:
            zoneMultiplier = 2.0
        case 70..<80:
            zoneMultiplier = 3.0
        case 80..<90:
            zoneMultiplier = 4.0
        default:
            zoneMultiplier = 5.0
        }

        return minutes * zoneMultiplier
    }

    /// Fallback estimation when no HR data available
    private func estimateTRIMPFromDuration(_ duration: TimeInterval) -> Double {
        let minutes = duration / 60.0
        // Assume moderate intensity (zone 3) for estimation
        return minutes * 3.0
    }

    // MARK: - Heart Rate Parameters

    private func getHeartRateParameters() async throws -> (hrMax: Double, hrRest: Double) {
        if let profile = try await userRepository.getUserProfile() {
            let hrMax = estimateHRMax(age: profile.age)
            let hrRest = estimateHRRest()
            return (hrMax, hrRest)
        }

        return (estimateHRMax(age: 30), estimateHRRest())
    }

    private func estimateHRMax(age: Int) -> Double {
        return Double(220 - age)
    }

    private func estimateHRRest() -> Double {
        return 60.0
    }
}
