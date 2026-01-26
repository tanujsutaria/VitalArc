//
//  CSVExporter.swift
//  VitalArc
//
//  CSV export functionality for data portability
//

import Foundation

/// Exports data to CSV format
final class CSVExporter {

    // MARK: - Workout Export

    /// Export workouts to CSV
    func exportWorkouts(startDate: Date, endDate: Date, workouts: [Workout]) async throws -> URL {
        var csv = "Date,Workout Name,Exercise,Set,Reps,Weight (kg),RIR,Rest (s),Notes\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for workout in workouts {
            let dateString = dateFormatter.string(from: workout.date)
            let workoutName = workout.name ?? "Workout"

            for set in workout.sets {
                let reps = set.actualReps ?? set.targetReps
                let weight = set.weight
                let rir = set.rir.map { String($0) } ?? ""
                let rest = set.restSeconds.map { String($0) } ?? ""
                let notes = set.notes?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""

                let row = [
                    dateString,
                    escapeCSV(workoutName),
                    escapeCSV(set.exerciseName),
                    String(set.setNumber),
                    String(reps),
                    String(format: "%.1f", weight),
                    rir,
                    rest,
                    escapeCSV(notes)
                ].joined(separator: ",")

                csv += row + "\n"
            }
        }

        return try saveCSV(csv, filename: "Workouts_\(dateFormatter.string(from: startDate))")
    }

    // MARK: - Nutrition Export

    /// Export nutrition data to CSV
    func exportNutrition(
        startDate: Date,
        endDate: Date,
        foodEntries: [FoodEntry],
        foods: [UUID: Food]
    ) async throws -> URL {
        var csv = "Date,Meal,Food,Brand,Quantity,Serving Unit,Calories,Protein (g),Carbs (g),Fat (g),Fiber (g),Sugar (g)\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        for entry in foodEntries {
            guard let food = foods[entry.foodId] else { continue }

            let dateString = dateFormatter.string(from: entry.date)
            let brand = food.brand ?? ""

            let row = [
                dateString,
                escapeCSV(entry.meal.displayName),
                escapeCSV(food.name),
                escapeCSV(brand),
                String(format: "%.1f", entry.quantity),
                escapeCSV(food.servingUnit),
                String(format: "%.0f", entry.calories),
                String(format: "%.1f", entry.protein),
                String(format: "%.1f", entry.carbs),
                String(format: "%.1f", entry.fat),
                String(format: "%.1f", food.fiber ?? 0),
                String(format: "%.1f", food.sugar ?? 0)
            ].joined(separator: ",")

            csv += row + "\n"
        }

        return try saveCSV(csv, filename: "Nutrition_\(dateFormatter.string(from: startDate).prefix(10))")
    }

    // MARK: - Body Metrics Export

    /// Export body metrics to CSV
    func exportBodyMetrics(startDate: Date, endDate: Date, snapshots: [ProgressSnapshot]) async throws -> URL {
        // Build header with all possible measurements
        var csv = "Date,Weight (kg),Body Fat %"
        for bodyPart in BodyPart.allCases {
            csv += ",\(bodyPart.displayName) (cm)"
        }
        csv += ",Notes\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for snapshot in snapshots.sorted(by: { $0.date < $1.date }) {
            let dateString = dateFormatter.string(from: snapshot.date)
            let weight = snapshot.bodyWeight.map { String(format: "%.1f", $0) } ?? ""
            let bodyFat = snapshot.bodyFatPercentage.map { String(format: "%.1f", $0) } ?? ""

            var row = [dateString, weight, bodyFat]

            // Add measurements for each body part
            for bodyPart in BodyPart.allCases {
                let measurement = snapshot.measurements.first { $0.bodyPart == bodyPart }
                let value = measurement.map { String(format: "%.1f", $0.value) } ?? ""
                row.append(value)
            }

            let notes = snapshot.notes?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
            row.append(escapeCSV(notes))

            csv += row.joined(separator: ",") + "\n"
        }

        return try saveCSV(csv, filename: "BodyMetrics_\(dateFormatter.string(from: startDate))")
    }

    // MARK: - Volume Metrics Export

    /// Export volume metrics to CSV
    func exportVolumeMetrics(metrics: [VolumeMetrics]) async throws -> URL {
        var csv = "Week Start,Week End,Exercise,Sets,Total Reps,Total Volume (kg),Avg Weight (kg),Avg RIR\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for metric in metrics {
            let weekStart = dateFormatter.string(from: metric.weekStartDate)
            let weekEnd = dateFormatter.string(from: metric.weekEndDate)

            for exerciseVolume in metric.exerciseVolumes {
                let avgRIR = exerciseVolume.avgRIR.map { String(format: "%.1f", $0) } ?? ""

                let row = [
                    weekStart,
                    weekEnd,
                    escapeCSV(exerciseVolume.exerciseName),
                    String(exerciseVolume.sets),
                    String(exerciseVolume.totalReps),
                    String(format: "%.1f", exerciseVolume.totalWeight),
                    String(format: "%.1f", exerciseVolume.avgWeight),
                    avgRIR
                ].joined(separator: ",")

                csv += row + "\n"
            }
        }

        return try saveCSV(csv, filename: "VolumeMetrics_\(dateFormatter.string(from: Date()))")
    }

    // MARK: - Helper Methods

    private func escapeCSV(_ text: String) -> String {
        if text.contains(",") || text.contains("\"") || text.contains("\n") {
            return "\"\(text.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return text
    }

    private func saveCSV(_ content: String, filename: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("\(filename).csv")

        try content.write(to: url, atomically: true, encoding: .utf8)

        return url
    }
}
