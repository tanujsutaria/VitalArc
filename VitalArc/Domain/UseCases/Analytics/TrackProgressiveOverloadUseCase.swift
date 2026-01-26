//
//  TrackProgressiveOverloadUseCase.swift
//  VitalArc
//
//  Use case for tracking progressive overload
//

import Foundation

/// Tracks progressive overload for exercises
final class TrackProgressiveOverloadUseCase {
    private let workoutRepository: WorkoutRepository

    init(workoutRepository: WorkoutRepository) {
        self.workoutRepository = workoutRepository
    }

    /// Analyze progressive overload for an exercise over time
    func execute(exerciseId: UUID, weeks: Int = 12) async throws -> ProgressiveOverloadData {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -weeks, to: endDate) else {
            throw ProgressiveOverloadError.invalidDateRange
        }

        // Fetch workouts in date range
        let workouts = try await workoutRepository.getWorkouts(from: startDate, to: endDate)

        // Group by week and calculate volume
        var weeklyVolumes: [(Date, Double)] = []

        for weekOffset in 0..<weeks {
            guard let weekDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: endDate),
                  let weekStart = calendar.dateInterval(of: .weekOfYear, for: weekDate)?.start else {
                continue
            }

            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekDate

            // Calculate volume for this week
            let weekWorkouts = workouts.filter { workout in
                workout.date >= weekStart && workout.date < weekEnd
            }

            var weekVolume = 0.0
            for workout in weekWorkouts {
                for set in workout.sets where set.exerciseId == exerciseId {
                    weekVolume += set.volume
                }
            }

            if weekVolume > 0 {
                weeklyVolumes.append((weekStart, weekVolume))
            }
        }

        weeklyVolumes.sort { $0.0 < $1.0 }

        // Analyze progression
        let isProgressing = analyzeProgression(weeklyVolumes)
        let volumeChange = calculateVolumeChange(weeklyVolumes)
        let needsDeload = detectDeloadNeed(weeklyVolumes)
        let recommendations = generateRecommendations(
            isProgressing: isProgressing,
            volumeChange: volumeChange,
            needsDeload: needsDeload,
            weeklyVolumes: weeklyVolumes
        )

        return ProgressiveOverloadData(
            isProgressing: isProgressing,
            weeklyVolumeChange: volumeChange,
            recommendations: recommendations,
            needsDeload: needsDeload,
            volumeHistory: weeklyVolumes
        )
    }

    // MARK: - Private Helpers

    private func analyzeProgression(_ volumes: [(Date, Double)]) -> Bool {
        guard volumes.count >= 3 else { return false }

        // Check if recent weeks show upward trend
        let recentWeeks = Array(volumes.suffix(4))
        var increasingWeeks = 0

        for i in 1..<recentWeeks.count {
            if recentWeeks[i].1 > recentWeeks[i-1].1 {
                increasingWeeks += 1
            }
        }

        // At least 2 out of 3 weeks should show increase
        return increasingWeeks >= 2
    }

    private func calculateVolumeChange(_ volumes: [(Date, Double)]) -> Double {
        guard volumes.count >= 2 else { return 0 }

        // Compare last 2 weeks average to first 2 weeks average
        let recentAvg = volumes.suffix(2).map { $0.1 }.reduce(0, +) / 2
        let initialAvg = volumes.prefix(2).map { $0.1 }.reduce(0, +) / 2

        guard initialAvg > 0 else { return 0 }

        return ((recentAvg - initialAvg) / initialAvg) * 100
    }

    private func detectDeloadNeed(_ volumes: [(Date, Double)]) -> Bool {
        guard volumes.count >= 4 else { return false }

        // Check for 3+ consecutive weeks of volume increase > 10%
        let recentWeeks = Array(volumes.suffix(4))
        var consecutiveIncreases = 0

        for i in 1..<recentWeeks.count {
            let change = ((recentWeeks[i].1 - recentWeeks[i-1].1) / recentWeeks[i-1].1) * 100
            if change > 10 {
                consecutiveIncreases += 1
            } else {
                consecutiveIncreases = 0
            }
        }

        return consecutiveIncreases >= 3
    }

    private func generateRecommendations(
        isProgressing: Bool,
        volumeChange: Double,
        needsDeload: Bool,
        weeklyVolumes: [(Date, Double)]
    ) -> [String] {
        var recommendations: [String] = []

        if needsDeload {
            recommendations.append("Consider a deload week: reduce volume by 40-50%")
            recommendations.append("Focus on technique and recovery")
            recommendations.append("Maintain intensity but reduce sets")
        } else if !isProgressing {
            recommendations.append("Try increasing volume by 5-10%")
            recommendations.append("Add 1-2 sets per exercise")
            recommendations.append("Consider changing exercise variation")
        } else {
            recommendations.append("Great progress! Keep it up")
            recommendations.append("Continue current progression")
            if volumeChange > 20 {
                recommendations.append("Monitor for signs of overtraining")
            }
        }

        // Volume-based recommendations
        if weeklyVolumes.count >= 4 {
            let recentVolume = weeklyVolumes.suffix(2).map { $0.1 }.reduce(0, +) / 2
            let previousVolume = weeklyVolumes.suffix(4).prefix(2).map { $0.1 }.reduce(0, +) / 2

            if recentVolume < previousVolume * 0.8 {
                recommendations.append("Volume has dropped significantly - check recovery")
            }
        }

        return recommendations
    }
}

enum ProgressiveOverloadError: Error {
    case invalidDateRange
    case insufficientData
}
