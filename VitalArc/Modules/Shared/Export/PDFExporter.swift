//
//  PDFExporter.swift
//  VitalArc
//
//  PDF export functionality for reports and logs with VitalArc branding
//

import Foundation
import UIKit
import PDFKit

/// Exports data to PDF format with VitalArc branding
final class PDFExporter {

    // MARK: - Brand Constants

    private let brandColor = UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1) // #6366F1
    private let headerBgColor = UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 0.08)
    private let sectionColor = UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1)
    private let bodyColor = UIColor.darkGray
    private let captionColor = UIColor.gray
    private let pageWidth: CGFloat = 612
    private let pageHeight: CGFloat = 792
    private let margin: CGFloat = 48
    private var contentWidth: CGFloat { pageWidth - margin * 2 }

    // MARK: - Progress Report Export

    /// Export a progress report to PDF
    func exportProgressReport(_ report: ProgressReport) async throws -> URL {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        let url = temporaryPDFURL(filename: "ProgressReport_\(formattedDate(report.period.start))")

        try renderer.writePDF(to: url) { context in
            context.beginPage()
            var y: CGFloat = margin

            // Branded header
            y = drawBrandedHeader(y: y)

            // Title
            y = drawTitle("Progress Report", y: y)

            // Date range subtitle
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateRange = "\(dateFormatter.string(from: report.period.start)) — \(dateFormatter.string(from: report.period.end))"
            y = drawCaption(dateRange, y: y)
            y += 12

            // Overall Score highlight box
            y = drawHighlightBox(
                title: "Overall Progress Score",
                value: "\(Int(report.progressScore))%",
                subtitle: report.summary,
                y: y
            )
            y += 16

            // Stats grid row
            var stats: [(String, String)] = []
            if let weightChange = report.bodyWeightChange {
                let sign = weightChange >= 0 ? "+" : ""
                stats.append(("Weight Change", "\(sign)\(String(format: "%.1f", weightChange)) kg"))
            }
            let volSign = report.volumeChange >= 0 ? "+" : ""
            stats.append(("Volume Change", "\(volSign)\(String(format: "%.1f", report.volumeChange))%"))
            stats.append(("Workout Consistency", "\(Int(report.workoutConsistency))%"))
            stats.append(("Nutrition Adherence", "\(Int(report.avgCalorieAdherence))%"))
            y = drawStatsGrid(stats, y: y)
            y += 12

            // Recovery Metrics
            if report.avgSleepHours != nil || report.avgHRV != nil {
                y = drawSectionHeader("Recovery Metrics", y: y, context: context)
                if let sleepHours = report.avgSleepHours {
                    y = drawBodyText("Average Sleep: \(String(format: "%.1f", sleepHours)) hours", y: y)
                }
                if let hrv = report.avgHRV {
                    y = drawBodyText("Average HRV: \(Int(hrv)) ms", y: y)
                }
                y += 8
            }

            // Personal Records
            if !report.recordsBroken.isEmpty {
                y = drawSectionHeader("Personal Records Broken (\(report.recordsBroken.count))", y: y, context: context)
                for record in report.recordsBroken.prefix(10) {
                    y = drawBulletItem(
                        "\(record.exerciseName): \(record.displayValue) (\(record.recordType.displayName))",
                        y: y,
                        context: context
                    )
                }
            }

            // Footer
            drawFooter(context: context)
        }

        return url
    }

    // MARK: - Workout Log Export

    /// Export workout logs to PDF
    func exportWorkoutLog(startDate: Date, endDate: Date, workouts: [Workout]) async throws -> URL {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        let url = temporaryPDFURL(filename: "WorkoutLog_\(formattedDate(startDate))")

        try renderer.writePDF(to: url) { context in
            context.beginPage()
            var y: CGFloat = margin

            // Branded header
            y = drawBrandedHeader(y: y)
            y = drawTitle("Workout Log", y: y)

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateRange = "\(dateFormatter.string(from: startDate)) — \(dateFormatter.string(from: endDate))"
            y = drawCaption(dateRange, y: y)
            y += 12

            drawDivider(y: y)
            y += 12

            // Workouts
            for workout in workouts {
                y = ensureSpace(y: y, needed: 80, context: context)

                // Workout header
                y = drawText(
                    workout.name ?? "Workout",
                    at: CGPoint(x: margin, y: y),
                    fontSize: 15,
                    isBold: true,
                    color: sectionColor
                )

                y = drawText(
                    dateFormatter.string(from: workout.date),
                    at: CGPoint(x: margin, y: y),
                    fontSize: 11,
                    color: captionColor
                )
                y += 4

                // Group by exercise
                let exerciseGroups = Dictionary(grouping: workout.sets) { $0.exerciseId }

                for (exerciseId, sets) in exerciseGroups {
                    y = ensureSpace(y: y, needed: 40, context: context)

                    y = drawText(
                        "Exercise: \(exerciseId.uuidString.prefix(8))...",
                        at: CGPoint(x: margin + 16, y: y),
                        fontSize: 12,
                        isBold: true,
                        color: bodyColor
                    )

                    for set in sets {
                        y = ensureSpace(y: y, needed: 16, context: context)
                        let rirText = set.rir.map { " (RIR: \($0))" } ?? ""
                        y = drawText(
                            "Set \(set.setNumber): \(set.reps) reps @ \(Int(set.weight)) kg\(rirText)",
                            at: CGPoint(x: margin + 32, y: y),
                            fontSize: 10,
                            color: bodyColor
                        )
                    }

                    y += 4
                }

                y += 8
                drawDivider(y: y, color: UIColor.lightGray.withAlphaComponent(0.4))
                y += 8
            }

            drawFooter(context: context)
        }

        return url
    }

    // MARK: - Branded Drawing Helpers

    private func drawBrandedHeader(y: CGFloat) -> CGFloat {
        var y = y

        // Brand accent bar
        let barRect = CGRect(x: margin, y: y, width: contentWidth, height: 4)
        let barPath = UIBezierPath(roundedRect: barRect, cornerRadius: 2)
        brandColor.setFill()
        barPath.fill()
        y += 14

        // App name
        let appAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: brandColor
        ]
        "VITALARC".draw(at: CGPoint(x: margin, y: y), withAttributes: appAttrs)
        y += 20

        return y
    }

    private func drawTitle(_ text: String, y: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black
        ]
        text.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        return y + 30
    }

    private func drawCaption(_ text: String, y: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: captionColor
        ]
        text.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        return y + 18
    }

    private func drawSectionHeader(_ text: String, y: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        var y = ensureSpace(y: y, needed: 40, context: context)

        drawDivider(y: y, color: UIColor.lightGray.withAlphaComponent(0.3))
        y += 10

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: sectionColor
        ]
        text.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        return y + 22
    }

    private func drawBodyText(_ text: String, y: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: bodyColor
        ]
        text.draw(at: CGPoint(x: margin + 8, y: y), withAttributes: attrs)
        return y + 18
    }

    private func drawBulletItem(_ text: String, y: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let y = ensureSpace(y: y, needed: 18, context: context)

        // Bullet dot
        let dotRect = CGRect(x: margin + 8, y: y + 5, width: 5, height: 5)
        let dotPath = UIBezierPath(ovalIn: dotRect)
        brandColor.setFill()
        dotPath.fill()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: bodyColor
        ]
        text.draw(at: CGPoint(x: margin + 20, y: y), withAttributes: attrs)
        return y + 17
    }

    private func drawHighlightBox(title: String, value: String, subtitle: String, y: CGFloat) -> CGFloat {
        let boxHeight: CGFloat = 72
        let boxRect = CGRect(x: margin, y: y, width: contentWidth, height: boxHeight)
        let boxPath = UIBezierPath(roundedRect: boxRect, cornerRadius: 8)
        headerBgColor.setFill()
        boxPath.fill()

        // Title
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: captionColor
        ]
        title.draw(at: CGPoint(x: margin + 16, y: y + 10), withAttributes: titleAttrs)

        // Value
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: brandColor
        ]
        value.draw(at: CGPoint(x: margin + 16, y: y + 26), withAttributes: valueAttrs)

        // Subtitle
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: bodyColor
        ]
        subtitle.draw(at: CGPoint(x: margin + 80, y: y + 32), withAttributes: subAttrs)

        return y + boxHeight
    }

    private func drawStatsGrid(_ stats: [(String, String)], y: CGFloat) -> CGFloat {
        let colWidth = contentWidth / 2
        var y = y

        for i in stride(from: 0, to: stats.count, by: 2) {
            let leftStat = stats[i]
            drawStatCell(title: leftStat.0, value: leftStat.1, x: margin, y: y)

            if i + 1 < stats.count {
                let rightStat = stats[i + 1]
                drawStatCell(title: rightStat.0, value: rightStat.1, x: margin + colWidth, y: y)
            }

            y += 40
        }

        return y
    }

    private func drawStatCell(title: String, value: String, x: CGFloat, y: CGFloat) {
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: captionColor
        ]
        title.draw(at: CGPoint(x: x, y: y), withAttributes: titleAttrs)

        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        value.draw(at: CGPoint(x: x, y: y + 14), withAttributes: valueAttrs)
    }

    private func drawDivider(y: CGFloat, color: UIColor? = nil) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: y))
        path.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        (color ?? brandColor.withAlphaComponent(0.2)).setStroke()
        path.lineWidth = 1
        path.stroke()
    }

    private func drawFooter(context: UIGraphicsPDFRendererContext) {
        let footerY = pageHeight - 36
        drawDivider(y: footerY - 8, color: UIColor.lightGray.withAlphaComponent(0.3))

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let footerText = "Generated by VitalArc — \(dateFormatter.string(from: Date()))"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: captionColor
        ]
        footerText.draw(at: CGPoint(x: margin, y: footerY), withAttributes: attrs)
    }

    private func ensureSpace(y: CGFloat, needed: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        if y + needed > pageHeight - 48 {
            drawFooter(context: context)
            context.beginPage()
            return margin
        }
        return y
    }

    // MARK: - Low-Level Text Drawing

    @discardableResult
    private func drawText(
        _ text: String,
        at point: CGPoint,
        fontSize: CGFloat,
        isBold: Bool = false,
        color: UIColor = .black
    ) -> CGFloat {
        let font = isBold ?
            UIFont.boldSystemFont(ofSize: fontSize) :
            UIFont.systemFont(ofSize: fontSize)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]

        text.draw(at: point, withAttributes: attributes)
        return point.y + fontSize + 4
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
