//
//  AnalyticsDashboardViewModel.swift
//  VitalArc
//
//  ViewModel for analytics dashboard
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class AnalyticsDashboardViewModel {
    private let calculateVolumeUseCase: CalculateVolumeUseCase
    private let trackProgressiveOverloadUseCase: TrackProgressiveOverloadUseCase
    private let generateProgressReportUseCase: GenerateProgressReportUseCase
    private let analyticsRepository: AnalyticsRepository
    // TODO: Add PDFExporter and CSVExporter to Xcode project
    // private let pdfExporter: PDFExporter
    // private let csvExporter: CSVExporter

    var selectedTimeRange: TimeRange = .month
    var currentReport: ProgressReport?
    var volumeMetrics: [VolumeMetrics] = []
    var progressSnapshots: [ProgressSnapshot] = []
    var personalRecords: [PersonalRecord] = []
    var isLoading = false
    var errorMessage: String?

    init(
        calculateVolumeUseCase: CalculateVolumeUseCase,
        trackProgressiveOverloadUseCase: TrackProgressiveOverloadUseCase,
        generateProgressReportUseCase: GenerateProgressReportUseCase,
        analyticsRepository: AnalyticsRepository
        // TODO: Add exporters once added to Xcode project
        // pdfExporter: PDFExporter = PDFExporter(),
        // csvExporter: CSVExporter = CSVExporter()
    ) {
        self.calculateVolumeUseCase = calculateVolumeUseCase
        self.trackProgressiveOverloadUseCase = trackProgressiveOverloadUseCase
        self.generateProgressReportUseCase = generateProgressReportUseCase
        self.analyticsRepository = analyticsRepository
        // self.pdfExporter = pdfExporter
        // self.csvExporter = csvExporter
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            let (startDate, endDate) = selectedTimeRange.dateRange()

            async let report = generateProgressReportUseCase.execute(startDate: startDate, endDate: endDate)
            async let volume = loadVolumeMetrics(startDate: startDate, endDate: endDate)
            async let snapshots = analyticsRepository.getProgressSnapshots(from: startDate, to: endDate)
            async let records = analyticsRepository.getPersonalRecords()

            currentReport = try await report
            volumeMetrics = try await volume
            progressSnapshots = try await snapshots
            personalRecords = try await records
        } catch {
            errorMessage = "Failed to load analytics: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func loadVolumeMetrics(startDate: Date, endDate: Date) async throws -> [VolumeMetrics] {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear ?? 4

        return try await calculateVolumeUseCase.executeForWeeks(weeks)
    }

    // MARK: - Export Functions

    func exportProgressReportPDF() async -> URL? {
        // TODO: Implement once PDFExporter is added to project
        errorMessage = "PDF export not yet implemented"
        return nil
        /*
        guard let report = currentReport else { return nil }

        do {
            return try await pdfExporter.exportProgressReport(report)
        } catch {
            errorMessage = "Failed to export PDF: \(error.localizedDescription)"
            return nil
        }
        */
    }

    func exportVolumeMetricsCSV() async -> URL? {
        // TODO: Implement once CSVExporter is added to project
        errorMessage = "CSV export not yet implemented"
        return nil
        /*
        guard !volumeMetrics.isEmpty else { return nil }

        do {
            return try await csvExporter.exportVolumeMetrics(metrics: volumeMetrics)
        } catch {
            errorMessage = "Failed to export CSV: \(error.localizedDescription)"
            return nil
        }
        */
    }

    // MARK: - Helper Types

    enum TimeRange: String, CaseIterable {
        case week = "1 Week"
        case month = "1 Month"
        case threeMonths = "3 Months"
        case sixMonths = "6 Months"
        case year = "1 Year"

        func dateRange() -> (Date, Date) {
            let end = Date()
            let calendar = Calendar.current
            var start: Date

            switch self {
            case .week:
                start = calendar.date(byAdding: .weekOfYear, value: -1, to: end) ?? end
            case .month:
                start = calendar.date(byAdding: .month, value: -1, to: end) ?? end
            case .threeMonths:
                start = calendar.date(byAdding: .month, value: -3, to: end) ?? end
            case .sixMonths:
                start = calendar.date(byAdding: .month, value: -6, to: end) ?? end
            case .year:
                start = calendar.date(byAdding: .year, value: -1, to: end) ?? end
            }

            return (start, end)
        }
    }
}
