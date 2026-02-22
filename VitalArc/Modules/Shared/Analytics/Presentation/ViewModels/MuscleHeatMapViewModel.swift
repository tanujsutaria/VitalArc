//
//  MuscleHeatMapViewModel.swift
//  VitalArc
//
//  ViewModel for muscle group heat map visualization
//

import Foundation
import SwiftUI

// MARK: - Data Types

/// Represents training data for a single muscle group
struct MuscleHeatMapData: Identifiable {
    let id = UUID()
    let muscleGroup: MuscleGroup
    let totalSets: Int
    let totalVolume: Double
    let sessionCount: Int
    let lastTrainedDate: Date?
    let exercises: [String]
    let intensityLevel: HeatMapIntensity
}

/// Heat map intensity levels based on weekly training volume
enum HeatMapIntensity: Int, CaseIterable, Comparable {
    case none = 0
    case veryLow = 1
    case low = 2
    case moderate = 3
    case high = 4
    case veryHigh = 5

    static func < (lhs: HeatMapIntensity, rhs: HeatMapIntensity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .none: return "Not Trained"
        case .veryLow: return "Very Low"
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .veryHigh: return "Very High"
        }
    }

    var color: Color {
        switch self {
        case .none: return Color.vitalAdaptiveSurface
        case .veryLow: return Color.vitalPrimary.opacity(0.15)
        case .low: return Color.vitalPrimary.opacity(0.3)
        case .moderate: return Color.vitalPrimary.opacity(0.5)
        case .high: return Color.vitalPrimary.opacity(0.75)
        case .veryHigh: return Color.vitalPrimary
        }
    }
}

/// Time range for heat map data
enum HeatMapTimeRange: String, CaseIterable {
    case week = "7 Days"
    case month = "30 Days"
    case threeMonths = "90 Days"

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        }
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class MuscleHeatMapViewModel {
    // MARK: - Dependencies

    private let workoutDataProvider: WorkoutDataProviding

    // MARK: - State

    var selectedTimeRange: HeatMapTimeRange = .month
    var muscleData: [MuscleHeatMapData] = []
    var selectedMuscle: MuscleHeatMapData?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Init

    init(workoutDataProvider: WorkoutDataProviding) {
        self.workoutDataProvider = workoutDataProvider
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate) else {
                isLoading = false
                return
            }

            let workouts = try await workoutDataProvider.getWorkouts(from: startDate, to: endDate)
            muscleData = try await buildMuscleData(from: workouts, weeks: Double(selectedTimeRange.days) / 7.0)
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .loading)
        }

        isLoading = false
    }

    // MARK: - Business Logic

    func buildMuscleData(from workouts: [Workout], weeks: Double) async throws -> [MuscleHeatMapData] {
        // Collect exercise IDs and look them up
        let allExerciseIds = Set(workouts.flatMap { $0.sets.map { $0.exerciseId } })
        var exerciseCache: [UUID: Exercise] = [:]

        for exerciseId in allExerciseIds {
            if let exercise = try await workoutDataProvider.getExercise(id: exerciseId) {
                exerciseCache[exerciseId] = exercise
            }
        }

        // Aggregate per muscle group
        var muscleAggregates: [MuscleGroup: MuscleAggregate] = [:]

        for workout in workouts {
            // Track which muscles were hit in this workout (for session counting)
            var musclesInWorkout: Set<MuscleGroup> = []

            for set in workout.sets {
                guard let exercise = exerciseCache[set.exerciseId] else { continue }

                for muscle in exercise.primaryMuscles {
                    if muscleAggregates[muscle] == nil {
                        muscleAggregates[muscle] = MuscleAggregate()
                    }
                    muscleAggregates[muscle]?.totalSets += 1
                    muscleAggregates[muscle]?.totalVolume += set.volume
                    muscleAggregates[muscle]?.exerciseNames.insert(exercise.name)

                    if let existing = muscleAggregates[muscle]?.lastTrainedDate {
                        if workout.date > existing {
                            muscleAggregates[muscle]?.lastTrainedDate = workout.date
                        }
                    } else {
                        muscleAggregates[muscle]?.lastTrainedDate = workout.date
                    }

                    musclesInWorkout.insert(muscle)
                }
            }

            for muscle in musclesInWorkout {
                muscleAggregates[muscle]?.sessionCount += 1
            }
        }

        // Convert to MuscleHeatMapData
        return muscleAggregates.map { muscle, aggregate in
            let weeklySets = weeks > 0 ? Double(aggregate.totalSets) / weeks : Double(aggregate.totalSets)
            let intensity = Self.calculateIntensity(weeklySets: weeklySets)

            return MuscleHeatMapData(
                muscleGroup: muscle,
                totalSets: aggregate.totalSets,
                totalVolume: aggregate.totalVolume,
                sessionCount: aggregate.sessionCount,
                lastTrainedDate: aggregate.lastTrainedDate,
                exercises: Array(aggregate.exerciseNames).sorted(),
                intensityLevel: intensity
            )
        }.sorted { $0.totalSets > $1.totalSets }
    }

    /// Map weekly sets to intensity level
    static func calculateIntensity(weeklySets: Double) -> HeatMapIntensity {
        switch weeklySets {
        case ..<1: return .none
        case 1..<4: return .veryLow
        case 4..<8: return .low
        case 8..<12: return .moderate
        case 12..<16: return .high
        default: return .veryHigh
        }
    }

    /// All MuscleGroups that represent trainable muscles (excludes fullBody)
    static let trainableMuscleGroups: [MuscleGroup] = [
        .chest, .shoulders, .triceps, .biceps, .forearms,
        .upperBack, .lowerBack, .lats, .traps, .rearDelts, .back,
        .quadriceps, .hamstrings, .glutes, .calves, .hipFlexors, .adductors, .abductors,
        .abs, .obliques, .serratus
    ]

    /// Returns data for all trainable muscles, filling in zeros for untrained ones
    var completeMuscleData: [MuscleHeatMapData] {
        let dataByMuscle = Dictionary(uniqueKeysWithValues: muscleData.map { ($0.muscleGroup, $0) })

        return Self.trainableMuscleGroups.map { muscle in
            if let existing = dataByMuscle[muscle] {
                return existing
            }
            return MuscleHeatMapData(
                muscleGroup: muscle,
                totalSets: 0,
                totalVolume: 0,
                sessionCount: 0,
                lastTrainedDate: nil,
                exercises: [],
                intensityLevel: .none
            )
        }
    }
}

// MARK: - Private Aggregate Helper

private struct MuscleAggregate {
    var totalSets: Int = 0
    var totalVolume: Double = 0
    var sessionCount: Int = 0
    var lastTrainedDate: Date?
    var exerciseNames: Set<String> = []
}
