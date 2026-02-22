//
//  CalculateNutritionStreakUseCase.swift
//  VitalArc
//
//  Use case for calculating nutrition logging streak
//

import Foundation

/// Result of a nutrition streak calculation
struct NutritionStreak: Equatable {
    let currentStreak: Int
    let longestStreak: Int
}

/// Use case for calculating consecutive days of food logging
final class CalculateNutritionStreakUseCase {
    private let repository: NutritionRepository

    init(repository: NutritionRepository) {
        self.repository = repository
    }

    /// Calculate current and longest nutrition logging streaks
    /// - Parameter maxLookbackDays: Maximum number of days to look back (default 365)
    /// - Returns: NutritionStreak with current and longest streak counts
    func execute(maxLookbackDays: Int = 365) async throws -> NutritionStreak {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let startDate = calendar.date(byAdding: .day, value: -maxLookbackDays, to: today) else {
            return NutritionStreak(currentStreak: 0, longestStreak: 0)
        }

        let entries = try await repository.getFoodEntries(from: startDate, to: Date())

        // Build set of days that have entries
        var daysWithEntries: Set<Int> = []
        for entry in entries {
            let dayStart = calendar.startOfDay(for: entry.date)
            let dayOffset = calendar.dateComponents([.day], from: startDate, to: dayStart).day ?? 0
            daysWithEntries.insert(dayOffset)
        }

        let todayOffset = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0

        // Calculate current streak (counting backward from today)
        // If today has no entries yet, start from yesterday to avoid breaking streaks early in the day
        var currentStreak = 0
        var dayToCheck = daysWithEntries.contains(todayOffset) ? todayOffset : todayOffset - 1
        while dayToCheck >= 0 && daysWithEntries.contains(dayToCheck) {
            currentStreak += 1
            dayToCheck -= 1
        }

        // Calculate longest streak
        var longestStreak = 0
        var runningStreak = 0
        for day in 0...todayOffset {
            if daysWithEntries.contains(day) {
                runningStreak += 1
                longestStreak = max(longestStreak, runningStreak)
            } else {
                runningStreak = 0
            }
        }

        return NutritionStreak(currentStreak: currentStreak, longestStreak: longestStreak)
    }
}
