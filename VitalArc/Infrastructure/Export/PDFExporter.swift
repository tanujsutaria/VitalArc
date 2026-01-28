//
//  PDFExporter.swift
//  VitalArc
//
//  PDF export functionality for reports and logs
//

import Foundation
import UIKit
import PDFKit

/// Exports data to PDF format
final class PDFExporter {

    // MARK: - Progress Report Export

    /// Export a progress report to PDF
    func exportProgressReport(_ report: ProgressReport) async throws -> URL {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792)) // Letter size

        let url = temporaryPDFURL(filename: "ProgressReport_\(formattedDate(report.period.start))")

        try renderer.writePDF(to: url) { context in
            context.beginPage()

            var yPosition: CGFloat = 40

            // Title
            drawText(
                "Progress Report",
                at: CGPoint(x: 40, y: yPosition),
                fontSize: 24,
                isBold: true
            )
            yPosition += 40

            // Date range
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateRange = "\(dateFormatter.string(from: report.period.start)) - \(dateFormatter.string(from: report.period.end))"
            drawText(dateRange, at: CGPoint(x: 40, y: yPosition), fontSize: 14)
            yPosition += 30

            // Overall Score
            drawText("Overall Progress Score", at: CGPoint(x: 40, y: yPosition), fontSize: 18, isBold: true)
            yPosition += 25
            drawText(
                "\(Int(report.progressScore))% - \(report.summary)",
                at: CGPoint(x: 40, y: yPosition),
                fontSize: 16
            )
            yPosition += 40

            // Body Weight Change
            if let weightChange = report.bodyWeightChange {
                drawText("Body Weight Change", at: CGPoint(x: 40, y: yPosition), fontSize: 18, isBold: true)
                yPosition += 25
                let sign = weightChange >= 0 ? "+" : ""
                drawText(
                    "\(sign)\(String(format: "%.1f", weightChange)) kg",
                    at: CGPoint(x: 40, y: yPosition),
                    fontSize: 16
                )
                yPosition += 30
            }

            // Training Volume
            drawText("Training Volume Change", at: CGPoint(x: 40, y: yPosition), fontSize: 18, isBold: true)
            yPosition += 25
            let sign = report.volumeChange >= 0 ? "+" : ""
            drawText(
                "\(sign)\(String(format: "%.1f", report.volumeChange))%",
                at: CGPoint(x: 40, y: yPosition),
                fontSize: 16
            )
            yPosition += 30

            // Consistency Metrics
            drawText("Consistency Metrics", at: CGPoint(x: 40, y: yPosition), fontSize: 18, isBold: true)
            yPosition += 25
            drawText(
                "Workout Consistency: \(Int(report.workoutConsistency))%",
                at: CGPoint(x: 40, y: yPosition),
                fontSize: 14
            )
            yPosition += 20
            drawText(
                "Nutrition Adherence: \(Int(report.avgCalorieAdherence))%",
                at: CGPoint(x: 40, y: yPosition),
                fontSize: 14
            )
            yPosition += 30

            // Recovery Metrics (if available)
            if let sleepHours = report.avgSleepHours {
                drawText("Recovery Metrics", at: CGPoint(x: 40, y: yPosition), fontSize: 18, isBold: true)
                yPosition += 25
                drawText(
                    "Average Sleep: \(String(format: "%.1f", sleepHours)) hours",
                    at: CGPoint(x: 40, y: yPosition),
                    fontSize: 14
                )
                yPosition += 20

                if let hrv = report.avgHRV {
                    drawText(
                        "Average HRV: \(Int(hrv)) ms",
                        at: CGPoint(x: 40, y: yPosition),
                        fontSize: 14
                    )
                    yPosition += 30
                }
            }

            // Personal Records
            if !report.recordsBroken.isEmpty {
                if yPosition > 700 {
                    context.beginPage()
                    yPosition = 40
                }

                drawText(
                    "Personal Records Broken (\(report.recordsBroken.count))",
                    at: CGPoint(x: 40, y: yPosition),
                    fontSize: 18,
                    isBold: true
                )
                yPosition += 25

                for record in report.recordsBroken.prefix(10) {
                    drawText(
                        "\(record.exerciseName): \(record.displayValue) (\(record.recordType.displayName))",
                        at: CGPoint(x: 40, y: yPosition),
                        fontSize: 12
                    )
                    yPosition += 18

                    if yPosition > 750 {
                        context.beginPage()
                        yPosition = 40
                    }
                }
            }
        }

        return url
    }

    // MARK: - Workout Log Export

    /// Export workout logs to PDF
    func exportWorkoutLog(startDate: Date, endDate: Date, workouts: [Workout]) async throws -> URL {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))

        let url = temporaryPDFURL(filename: "WorkoutLog_\(formattedDate(startDate))")

        try renderer.writePDF(to: url) { context in
            context.beginPage()
            var yPosition: CGFloat = 40

            // Title
            drawText("Workout Log", at: CGPoint(x: 40, y: yPosition), fontSize: 24, isBold: true)
            yPosition += 40

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateRange = "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
            drawText(dateRange, at: CGPoint(x: 40, y: yPosition), fontSize: 14)
            yPosition += 40

            // Workouts
            for workout in workouts {
                if yPosition > 700 {
                    context.beginPage()
                    yPosition = 40
                }

                // Workout header
                drawText(
                    workout.name ?? "Workout",
                    at: CGPoint(x: 40, y: yPosition),
                    fontSize: 16,
                    isBold: true
                )
                yPosition += 20

                drawText(
                    dateFormatter.string(from: workout.date),
                    at: CGPoint(x: 40, y: yPosition),
                    fontSize: 12
                )
                yPosition += 20

                // Group by exercise
                let exerciseGroups = Dictionary(grouping: workout.sets) { $0.exerciseId }

                for (exerciseId, sets) in exerciseGroups {
                    drawText(
                        "Exercise: \(exerciseId.uuidString.prefix(8))...",
                        at: CGPoint(x: 60, y: yPosition),
                        fontSize: 14,
                        isBold: true
                    )
                    yPosition += 18

                    for set in sets {
                        let rirText = set.rir.map { " (RIR: \($0))" } ?? ""

                        drawText(
                            "Set \(set.setNumber): \(set.reps) reps @ \(Int(set.weight)) kg\(rirText)",
                            at: CGPoint(x: 80, y: yPosition),
                            fontSize: 11
                        )
                        yPosition += 15

                        if yPosition > 750 {
                            context.beginPage()
                            yPosition = 40
                        }
                    }

                    yPosition += 5
                }

                yPosition += 15
            }
        }

        return url
    }

    // MARK: - Helper Methods

    private func drawText(
        _ text: String,
        at point: CGPoint,
        fontSize: CGFloat,
        isBold: Bool = false
    ) {
        let font = isBold ?
            UIFont.boldSystemFont(ofSize: fontSize) :
            UIFont.systemFont(ofSize: fontSize)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]

        text.draw(at: point, withAttributes: attributes)
    }

    private func temporaryPDFURL(filename: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("\(filename).pdf")
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
