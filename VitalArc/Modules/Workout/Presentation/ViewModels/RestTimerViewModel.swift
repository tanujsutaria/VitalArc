//
//  RestTimerViewModel.swift
//  VitalArc
//
//  ViewModel for configuring rest timer settings
//

import Foundation
import Observation

@MainActor
@Observable
final class RestTimerViewModel {
    /// Default rest duration in seconds
    var defaultRestDuration: Int = 90

    /// Per-exercise rest duration overrides
    var exerciseRestDurations: [UUID: Int] = [:]

    /// Progressive rest: seconds added per completed set (0 = disabled)
    var progressiveRestIncrement: Int = 0

    /// Track completed set counts per exercise for progressive calculation
    private(set) var completedSetCounts: [UUID: Int] = [:]

    // MARK: - Configuration

    /// Available rest duration presets in seconds
    static let restPresets: [Int] = [30, 60, 90, 120, 180, 300]

    /// Available progressive increment presets in seconds
    static let progressivePresets: [Int] = [0, 10, 15, 30]

    /// Set rest duration for a specific exercise
    func setRestDuration(_ duration: Int, for exerciseId: UUID) {
        exerciseRestDurations[exerciseId] = duration
    }

    /// Get effective rest duration for an exercise (with progressive rest applied)
    func effectiveRestDuration(for exerciseId: UUID) -> Int {
        let baseDuration = exerciseRestDurations[exerciseId] ?? defaultRestDuration
        let completedSets = completedSetCounts[exerciseId] ?? 0

        if progressiveRestIncrement > 0 && completedSets > 0 {
            return baseDuration + (progressiveRestIncrement * completedSets)
        }
        return baseDuration
    }

    /// Record a completed set for progressive rest tracking
    func recordCompletedSet(for exerciseId: UUID) {
        completedSetCounts[exerciseId, default: 0] += 1
    }

    /// Reset completed set counts (e.g., when workout resets)
    func resetCounts() {
        completedSetCounts = [:]
    }

    /// Calculate progressive rest for a given set number
    static func progressiveRestDuration(baseDuration: Int, increment: Int, setNumber: Int) -> Int {
        guard increment > 0, setNumber > 1 else { return baseDuration }
        return baseDuration + (increment * (setNumber - 1))
    }

    /// Format seconds to display string
    static func formatDuration(_ seconds: Int) -> String {
        if seconds >= 60 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds == 0 {
                return "\(minutes)m"
            }
            return "\(minutes)m \(remainingSeconds)s"
        }
        return "\(seconds)s"
    }
}
