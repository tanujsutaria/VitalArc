//
//  VolumeAnalysisViewModel.swift
//  VitalArc
//
//  ViewModel for per-muscle-group volume and frequency analysis
//

import Foundation
import SwiftUI

// MARK: - Data Types

/// Size category for recommended volume ranges
enum MuscleSizeCategory: String {
    case small
    case medium
    case large

    var recommendedSetsRange: ClosedRange<Int> {
        switch self {
        case .small: return 10...14
        case .medium: return 12...18
        case .large: return 14...20
        }
    }

    var label: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
}

/// Analysis data for a single muscle group
struct MuscleVolumeAnalysis: Identifiable {
    let id = UUID()
    let muscleGroup: MuscleGroup
    let weeklySets: Int
    let weeklyVolume: Double
    let recommendedRange: ClosedRange<Int>
    let sizeCategory: MuscleSizeCategory
    let frequency: Double
    let daysSinceLastTrained: Int?
    let weeklyTrend: [WeeklySetData]

    var volumeStatus: VolumeStatus {
        if weeklySets < recommendedRange.lowerBound {
            return .underVolume
        } else if weeklySets > recommendedRange.upperBound {
            return .overVolume
        }
        return .optimal
    }

    var recoveryStatus: RecoveryStatus {
        guard let days = daysSinceLastTrained else { return .unknown }
        switch days {
        case 0...1: return .recovering
        case 2...3: return .ready
        case 4...5: return .rested
        default: return .overdue
        }
    }
}

/// Weekly sets for trend charts
struct WeeklySetData: Identifiable {
    let id = UUID()
    let weekStart: Date
    let sets: Int
    let volume: Double
}

/// Volume status relative to recommended range
enum VolumeStatus: String {
    case underVolume = "Under"
    case optimal = "Optimal"
    case overVolume = "Over"

    var color: Color {
        switch self {
        case .underVolume: return .vitalWarning
        case .optimal: return .vitalSuccess
        case .overVolume: return .vitalDanger
        }
    }
}

/// Recovery readiness based on days since last trained
enum RecoveryStatus: String {
    case recovering = "Recovering"
    case ready = "Ready"
    case rested = "Rested"
    case overdue = "Overdue"
    case unknown = "Unknown"

    var color: Color {
        switch self {
        case .recovering: return .vitalWarning
        case .ready: return .vitalSuccess
        case .rested: return .vitalInfo
        case .overdue: return .vitalDanger
        case .unknown: return .vitalAdaptiveTextSecondary
        }
    }
}

/// Summary of volume analysis across all muscles
struct VolumeAnalysisSummary {
    let mostTrainedMuscle: MuscleGroup?
    let leastTrainedMuscle: MuscleGroup?
    let musclesUnderVolume: [MuscleGroup]
    let musclesOverVolume: [MuscleGroup]
    let musclesOptimal: [MuscleGroup]
}

// MARK: - ViewModel

@MainActor
@Observable
final class VolumeAnalysisViewModel {
    // MARK: - Dependencies

    private let workoutRepository: WorkoutRepository

    // MARK: - State

    var analyses: [MuscleVolumeAnalysis] = []
    var selectedMuscle: MuscleGroup?
    var weeksToAnalyze: Int = 8
    var isLoading = false
    var errorMessage: String?

    // MARK: - Init

    init(workoutRepository: WorkoutRepository) {
        self.workoutRepository = workoutRepository
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .weekOfYear, value: -weeksToAnalyze, to: endDate) else {
                isLoading = false
                return
            }

            let workouts = try await workoutRepository.getWorkouts(from: startDate, to: endDate)
            analyses = try await buildAnalyses(from: workouts, startDate: startDate, endDate: endDate, weeks: weeksToAnalyze)
        } catch {
            errorMessage = UserFacingError.message(for: error, context: .loading)
        }

        isLoading = false
    }

    // MARK: - Business Logic

    func buildAnalyses(from workouts: [Workout], startDate: Date, endDate: Date, weeks: Int) async throws -> [MuscleVolumeAnalysis] {
        let calendar = Calendar.current

        // Cache exercises
        let allExerciseIds = Set(workouts.flatMap { $0.sets.map { $0.exerciseId } })
        var exerciseCache: [UUID: Exercise] = [:]
        for exerciseId in allExerciseIds {
            if let exercise = try await workoutRepository.getExercise(id: exerciseId) {
                exerciseCache[exerciseId] = exercise
            }
        }

        // Build weekly buckets
        var weeklyBuckets: [Date: [Workout]] = [:]
        for workout in workouts {
            if let weekStart = calendar.dateInterval(of: .weekOfYear, for: workout.date)?.start {
                weeklyBuckets[weekStart, default: []].append(workout)
            }
        }

        // Per-muscle aggregation
        var muscleWeeklyData: [MuscleGroup: [Date: MuscleWeekBucket]] = [:]
        var muscleLastTrained: [MuscleGroup: Date] = [:]
        var muscleSessions: [MuscleGroup: Set<UUID>] = [:]

        for workout in workouts {
            var musclesInWorkout: Set<MuscleGroup> = []

            for set in workout.sets {
                guard let exercise = exerciseCache[set.exerciseId] else { continue }

                for muscle in exercise.primaryMuscles {
                    let weekStart = calendar.dateInterval(of: .weekOfYear, for: workout.date)?.start ?? workout.date

                    if muscleWeeklyData[muscle] == nil {
                        muscleWeeklyData[muscle] = [:]
                    }
                    if muscleWeeklyData[muscle]?[weekStart] == nil {
                        muscleWeeklyData[muscle]?[weekStart] = MuscleWeekBucket()
                    }

                    muscleWeeklyData[muscle]?[weekStart]?.sets += 1
                    muscleWeeklyData[muscle]?[weekStart]?.volume += set.volume

                    if let existing = muscleLastTrained[muscle] {
                        if workout.date > existing {
                            muscleLastTrained[muscle] = workout.date
                        }
                    } else {
                        muscleLastTrained[muscle] = workout.date
                    }

                    musclesInWorkout.insert(muscle)
                }
            }

            for muscle in musclesInWorkout {
                muscleSessions[muscle, default: []].insert(workout.id)
            }
        }

        // Build analyses
        var results: [MuscleVolumeAnalysis] = []

        for (muscle, weekData) in muscleWeeklyData {
            let sizeCategory = Self.muscleSizeCategory(for: muscle)

            // Current week sets
            let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: endDate)?.start
            let currentWeekSets = currentWeekStart.flatMap { weekData[$0]?.sets } ?? 0
            let currentWeekVolume = currentWeekStart.flatMap { weekData[$0]?.volume } ?? 0

            // Frequency: sessions per week
            let totalSessions = muscleSessions[muscle]?.count ?? 0
            let frequency = weeks > 0 ? Double(totalSessions) / Double(weeks) : 0

            // Days since last trained
            let daysSince: Int? = muscleLastTrained[muscle].map { lastDate in
                calendar.dateComponents([.day], from: lastDate, to: endDate).day ?? 0
            }

            // Weekly trend
            let trend = buildWeeklyTrend(weekData: weekData, startDate: startDate, endDate: endDate, calendar: calendar)

            results.append(MuscleVolumeAnalysis(
                muscleGroup: muscle,
                weeklySets: currentWeekSets,
                weeklyVolume: currentWeekVolume,
                recommendedRange: sizeCategory.recommendedSetsRange,
                sizeCategory: sizeCategory,
                frequency: frequency,
                daysSinceLastTrained: daysSince,
                weeklyTrend: trend
            ))
        }

        return results.sorted { $0.weeklySets > $1.weeklySets }
    }

    private func buildWeeklyTrend(weekData: [Date: MuscleWeekBucket], startDate: Date, endDate: Date, calendar: Calendar) -> [WeeklySetData] {
        var trend: [WeeklySetData] = []
        var currentDate = startDate

        while currentDate < endDate {
            if let weekStart = calendar.dateInterval(of: .weekOfYear, for: currentDate)?.start {
                let bucket = weekData[weekStart]
                trend.append(WeeklySetData(
                    weekStart: weekStart,
                    sets: bucket?.sets ?? 0,
                    volume: bucket?.volume ?? 0
                ))
            }
            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) else { break }
            currentDate = nextWeek
        }

        return trend
    }

    // MARK: - Muscle Size Classification

    static func muscleSizeCategory(for muscle: MuscleGroup) -> MuscleSizeCategory {
        switch muscle {
        case .biceps, .triceps, .calves, .forearms, .rearDelts, .serratus:
            return .small
        case .shoulders, .chest, .upperBack, .lats, .traps, .back, .lowerBack,
             .abs, .obliques, .hipFlexors, .adductors, .abductors:
            return .medium
        case .quadriceps, .hamstrings, .glutes, .fullBody:
            return .large
        }
    }

    // MARK: - Computed Summary

    var summary: VolumeAnalysisSummary {
        let mostTrained = analyses.max(by: { $0.weeklySets < $1.weeklySets })?.muscleGroup
        let leastTrained = analyses.filter { $0.weeklySets > 0 }.min(by: { $0.weeklySets < $1.weeklySets })?.muscleGroup

        let under = analyses.filter { $0.volumeStatus == .underVolume }.map { $0.muscleGroup }
        let over = analyses.filter { $0.volumeStatus == .overVolume }.map { $0.muscleGroup }
        let optimal = analyses.filter { $0.volumeStatus == .optimal }.map { $0.muscleGroup }

        return VolumeAnalysisSummary(
            mostTrainedMuscle: mostTrained,
            leastTrainedMuscle: leastTrained,
            musclesUnderVolume: under,
            musclesOverVolume: over,
            musclesOptimal: optimal
        )
    }

    /// Analysis for the currently selected muscle, or nil
    var selectedAnalysis: MuscleVolumeAnalysis? {
        guard let selected = selectedMuscle else { return nil }
        return analyses.first { $0.muscleGroup == selected }
    }
}

// MARK: - Private Types

private struct MuscleWeekBucket {
    var sets: Int = 0
    var volume: Double = 0
}
