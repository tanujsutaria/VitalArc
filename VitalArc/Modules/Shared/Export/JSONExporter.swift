//
//  JSONExporter.swift
//  VitalArc
//
//  JSON export functionality for structured data portability
//

import Foundation

/// Exports data to JSON format for interoperability
final class JSONExporter {

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    // MARK: - Workout Export

    /// Export workouts to JSON
    func exportWorkouts(
        startDate: Date,
        endDate: Date,
        workouts: [Workout],
        exerciseNames: [UUID: String] = [:]
    ) async throws -> URL {
        let export = WorkoutExport(
            exportDate: Date(),
            period: ExportPeriod(start: startDate, end: endDate),
            workoutCount: workouts.count,
            workouts: workouts.map { workout in
                WorkoutExport.WorkoutEntry(
                    id: workout.id.uuidString,
                    name: workout.name ?? "Workout",
                    date: workout.date,
                    duration: workout.duration,
                    sets: workout.sets.map { set in
                        WorkoutExport.SetEntry(
                            exerciseId: set.exerciseId.uuidString,
                            exerciseName: exerciseNames[set.exerciseId] ?? "Unknown",
                            setNumber: set.setNumber,
                            reps: set.reps,
                            weight: set.weight,
                            rir: set.rir,
                            rpe: set.rpe
                        )
                    }
                )
            }
        )

        let data = try encoder.encode(export)
        return try saveJSON(data, filename: "Workouts_\(formattedDate(startDate))")
    }

    // MARK: - Nutrition Export

    /// Export nutrition data to JSON
    func exportNutrition(
        startDate: Date,
        endDate: Date,
        foodEntries: [FoodEntry],
        foods: [UUID: Food]
    ) async throws -> URL {
        let filteredEntries: [NutritionExport.NutritionEntry] = foodEntries.compactMap { entry in
            guard let food = foods[entry.foodId] else { return nil }
            return NutritionExport.NutritionEntry(
                date: entry.date,
                meal: entry.meal.displayName,
                food: food.name,
                brand: food.brand,
                quantity: entry.quantity,
                servingUnit: food.servingUnit,
                calories: entry.calories,
                protein: entry.protein,
                carbs: entry.carbs,
                fat: entry.fat,
                fiber: food.fiber,
                sugar: food.sugar
            )
        }

        let export = NutritionExport(
            exportDate: Date(),
            period: ExportPeriod(start: startDate, end: endDate),
            entryCount: filteredEntries.count,
            entries: filteredEntries
        )

        let data = try encoder.encode(export)
        return try saveJSON(data, filename: "Nutrition_\(formattedDate(startDate))")
    }

    // MARK: - Body Metrics Export

    /// Export body metrics to JSON
    func exportBodyMetrics(startDate: Date, endDate: Date, snapshots: [ProgressSnapshot]) async throws -> URL {
        let export = BodyMetricsExport(
            exportDate: Date(),
            period: ExportPeriod(start: startDate, end: endDate),
            snapshotCount: snapshots.count,
            snapshots: snapshots.sorted(by: { $0.date < $1.date }).map { snapshot in
                BodyMetricsExport.MetricsEntry(
                    date: snapshot.date,
                    bodyWeight: snapshot.bodyWeight,
                    bodyFatPercentage: snapshot.bodyFatPercentage,
                    measurements: snapshot.measurements.map { m in
                        BodyMetricsExport.Measurement(
                            bodyPart: m.bodyPart.displayName,
                            value: m.value
                        )
                    },
                    notes: snapshot.notes
                )
            }
        )

        let data = try encoder.encode(export)
        return try saveJSON(data, filename: "BodyMetrics_\(formattedDate(startDate))")
    }

    // MARK: - Progress Report Export

    /// Export a progress report to JSON
    func exportProgressReport(_ report: ProgressReport) async throws -> URL {
        let export = ProgressReportExport(
            exportDate: Date(),
            period: ExportPeriod(start: report.period.start, end: report.period.end),
            progressScore: report.progressScore,
            summary: report.summary,
            bodyWeightChange: report.bodyWeightChange,
            volumeChange: report.volumeChange,
            workoutConsistency: report.workoutConsistency,
            avgCalorieAdherence: report.avgCalorieAdherence,
            avgSleepHours: report.avgSleepHours,
            avgHRV: report.avgHRV,
            recordsBroken: report.recordsBroken.map { record in
                ProgressReportExport.RecordEntry(
                    exerciseName: record.exerciseName,
                    recordType: record.recordType.rawValue,
                    value: record.value,
                    reps: record.reps,
                    date: record.date
                )
            }
        )

        let data = try encoder.encode(export)
        return try saveJSON(data, filename: "ProgressReport_\(formattedDate(report.period.start))")
    }

    // MARK: - Helpers

    private func saveJSON(_ data: Data, filename: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("\(filename).json")
        try data.write(to: url)
        return url
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Export DTOs

private struct ExportPeriod: Codable {
    let start: Date
    let end: Date
}

private struct WorkoutExport: Codable {
    let exportDate: Date
    let period: ExportPeriod
    let workoutCount: Int
    let workouts: [WorkoutEntry]

    struct WorkoutEntry: Codable {
        let id: String
        let name: String
        let date: Date
        let duration: TimeInterval?
        let sets: [SetEntry]
    }

    struct SetEntry: Codable {
        let exerciseId: String
        let exerciseName: String
        let setNumber: Int
        let reps: Int
        let weight: Double
        let rir: Int?
        let rpe: Double?
    }
}

private struct NutritionExport: Codable {
    let exportDate: Date
    let period: ExportPeriod
    let entryCount: Int
    let entries: [NutritionEntry]

    struct NutritionEntry: Codable {
        let date: Date
        let meal: String
        let food: String
        let brand: String?
        let quantity: Double
        let servingUnit: String
        let calories: Double
        let protein: Double
        let carbs: Double
        let fat: Double
        let fiber: Double?
        let sugar: Double?
    }
}

private struct BodyMetricsExport: Codable {
    let exportDate: Date
    let period: ExportPeriod
    let snapshotCount: Int
    let snapshots: [MetricsEntry]

    struct MetricsEntry: Codable {
        let date: Date
        let bodyWeight: Double?
        let bodyFatPercentage: Double?
        let measurements: [Measurement]
        let notes: String?
    }

    struct Measurement: Codable {
        let bodyPart: String
        let value: Double
    }
}

private struct ProgressReportExport: Codable {
    let exportDate: Date
    let period: ExportPeriod
    let progressScore: Double
    let summary: String
    let bodyWeightChange: Double?
    let volumeChange: Double
    let workoutConsistency: Double
    let avgCalorieAdherence: Double
    let avgSleepHours: Double?
    let avgHRV: Double?
    let recordsBroken: [RecordEntry]

    struct RecordEntry: Codable {
        let exerciseName: String
        let recordType: String
        let value: Double
        let reps: Int?
        let date: Date
    }
}
