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
    private let healthKitManager: HealthKitManager

    /// Scaling factor for converting raw TRIMP to 0-21 strain score
    /// Based on typical TRIMP values: 50-300 TRIMP = 0-21 strain
    private let trimpToStrainScaleFactor: Double = 21.0 / 250.0

    init(
        healthRepository: HealthRepository,
        userRepository: UserRepository,
        healthKitManager: HealthKitManager = HealthKitManager()
    ) {
        self.healthRepository = healthRepository
        self.userRepository = userRepository
        self.healthKitManager = healthKitManager
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
        let (hrMax, hrRest, biologicalSex) = try await getHeartRateParameters()

        // Fetch actual workouts from HealthKit
        let workoutDataList = try await healthKitManager.fetchWorkoutData(for: date)

        // No workouts on this day
        guard !workoutDataList.isEmpty else {
            return StrainResult(
                date: date,
                trimpScore: 0,
                strainScore: 0,
                duration: 0,
                workoutCount: 0,
                calculationMethod: .estimated
            )
        }

        // Aggregate TRIMP across all workouts
        var totalTrimp: Double = 0
        var totalDuration: TimeInterval = 0
        var allHRSamples: [Double] = []
        var maxHR: Double = 0
        var usedBanister = false

        for workout in workoutDataList {
            totalDuration += workout.duration

            if !workout.heartRateSamples.isEmpty {
                // Use Banister method with HR samples (most accurate)
                let trimp = calculateBanisterTRIMP(
                    samples: workout.heartRateSamples,
                    duration: workout.duration,
                    hrMax: hrMax,
                    hrRest: hrRest,
                    biologicalSex: biologicalSex
                )
                totalTrimp += trimp
                usedBanister = true

                // Track HR stats
                let hrValues = workout.heartRateSamples.map(\.bpm)
                allHRSamples.append(contentsOf: hrValues)
                if let workoutMax = hrValues.max() {
                    maxHR = max(maxHR, workoutMax)
                }

            } else if let avgHR = workout.averageHeartRate {
                // Use Edwards method with average HR
                let trimp = calculateEdwardsTRIMP(
                    averageHR: avgHR,
                    duration: workout.duration,
                    hrMax: hrMax
                )
                totalTrimp += trimp
                allHRSamples.append(avgHR)
                maxHR = max(maxHR, avgHR)

            } else {
                // Fallback: estimate based on duration
                totalTrimp += estimateTRIMPFromDuration(workout.duration)
            }
        }

        // Calculate averages
        let averageHR: Double? = allHRSamples.isEmpty ? nil : allHRSamples.reduce(0, +) / Double(allHRSamples.count)
        let hrReserve: Double? = averageHR.map { ($0 - hrRest) / (hrMax - hrRest) * 100 }

        // Convert to strain score (0-21 scale)
        let strainScore = min(totalTrimp * trimpToStrainScaleFactor, 21.0)

        // Determine calculation method used
        let method: StrainResult.TRIMPMethod
        if usedBanister {
            method = .banister
        } else if !allHRSamples.isEmpty {
            method = .edwards
        } else {
            method = .estimated
        }

        return StrainResult(
            date: date,
            trimpScore: totalTrimp,
            strainScore: strainScore,
            duration: totalDuration,
            averageHeartRate: averageHR,
            maxHeartRate: maxHR > 0 ? maxHR : nil,
            heartRateReserve: hrReserve,
            workoutCount: workoutDataList.count,
            calculationMethod: method
        )
    }

    /// Calculate strain from provided workout data (for in-app logged workouts)
    func execute(for workouts: [WorkoutData], on date: Date) async throws -> StrainResult? {
        guard !workouts.isEmpty else {
            return StrainResult(
                date: date,
                trimpScore: 0,
                strainScore: 0,
                duration: 0,
                workoutCount: 0,
                calculationMethod: .estimated
            )
        }

        let (hrMax, hrRest, biologicalSex) = try await getHeartRateParameters()

        var totalTrimp: Double = 0
        var totalDuration: TimeInterval = 0
        var allHRSamples: [Double] = []
        var maxHR: Double = 0
        var usedBanister = false

        for workout in workouts {
            totalDuration += workout.duration

            if !workout.heartRateSamples.isEmpty {
                let trimp = calculateBanisterTRIMP(
                    samples: workout.heartRateSamples,
                    duration: workout.duration,
                    hrMax: hrMax,
                    hrRest: hrRest,
                    biologicalSex: biologicalSex
                )
                totalTrimp += trimp
                usedBanister = true

                let hrValues = workout.heartRateSamples.map(\.bpm)
                allHRSamples.append(contentsOf: hrValues)
                if let workoutMax = hrValues.max() {
                    maxHR = max(maxHR, workoutMax)
                }

            } else if let avgHR = workout.averageHeartRate {
                let trimp = calculateEdwardsTRIMP(
                    averageHR: avgHR,
                    duration: workout.duration,
                    hrMax: hrMax
                )
                totalTrimp += trimp
                allHRSamples.append(avgHR)
                maxHR = max(maxHR, avgHR)

            } else {
                totalTrimp += estimateTRIMPFromDuration(workout.duration)
            }
        }

        let averageHR: Double? = allHRSamples.isEmpty ? nil : allHRSamples.reduce(0, +) / Double(allHRSamples.count)
        let hrReserve: Double? = averageHR.map { ($0 - hrRest) / (hrMax - hrRest) * 100 }
        let strainScore = min(totalTrimp * trimpToStrainScaleFactor, 21.0)

        let method: StrainResult.TRIMPMethod
        if usedBanister {
            method = .banister
        } else if !allHRSamples.isEmpty {
            method = .edwards
        } else {
            method = .estimated
        }

        return StrainResult(
            date: date,
            trimpScore: totalTrimp,
            strainScore: strainScore,
            duration: totalDuration,
            averageHeartRate: averageHR,
            maxHeartRate: maxHR > 0 ? maxHR : nil,
            heartRateReserve: hrReserve,
            workoutCount: workouts.count,
            calculationMethod: method
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
        hrRest: Double,
        biologicalSex: BiologicalSex = .male
    ) -> Double {
        guard !samples.isEmpty else { return 0 }

        // Exponential factor based on biological sex (Banister 1991)
        // Males: 1.92, Females: 1.67, Other: average of both
        let exponentialFactor: Double
        switch biologicalSex {
        case .male:
            exponentialFactor = 1.92
        case .female:
            exponentialFactor = 1.67
        case .other:
            exponentialFactor = 1.795 // Average of male/female
        }
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

    private func getHeartRateParameters() async throws -> (hrMax: Double, hrRest: Double, sex: BiologicalSex) {
        if let profile = try await userRepository.getUserProfile() {
            // Use custom HR max if set, otherwise estimate from age
            let hrMax = Double(profile.effectiveHRMax)

            // Use custom HR resting if set, otherwise try HealthKit, then estimate
            let hrRest: Double
            if let customResting = profile.customHRResting {
                hrRest = Double(customResting)
            } else {
                hrRest = await getRestingHeartRate() ?? Double(profile.estimatedHRResting)
            }

            return (hrMax, hrRest, profile.biologicalSex)
        }

        return (estimateHRMax(age: 30), estimateHRRest(), .male)
    }

    private func getRestingHeartRate() async -> Double? {
        // Get resting HR over last 7 days for a more reliable baseline
        let dateRange = HealthKitQuery.dateRangeForLastDays(7)
        guard let metrics = try? await healthKitManager.fetchHealthMetrics(from: dateRange.start, to: dateRange.end) else {
            return nil
        }

        let restingHRValues = metrics.compactMap(\.restingHeartRate)
        guard !restingHRValues.isEmpty else { return nil }

        return restingHRValues.reduce(0, +) / Double(restingHRValues.count)
    }

    private func estimateHRMax(age: Int) -> Double {
        return Double(220 - age)
    }

    private func estimateHRRest() -> Double {
        return 60.0
    }
}
