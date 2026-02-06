//
//  HealthKitQuery.swift
//  VitalArc
//
//  Helper methods for HealthKit queries
//

import Foundation
import HealthKit

/// Helper struct for building HealthKit queries
struct HealthKitQuery {

    // MARK: - Date Range Helpers

    /// Compute start of next day from a given start-of-day. DST-safe via Calendar.
    /// Uses guard + assertionFailure for safety: returns startOfDay + 86400 as last-resort fallback.
    private static func endOfDay(from startOfDay: Date) -> Date {
        guard let next = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            assertionFailure("Calendar.date(byAdding: .day) returned nil for \(startOfDay)")
            return startOfDay.addingTimeInterval(86400)
        }
        return next
    }

    /// Returns date range for today (start of day to end of day)
    static func dateRangeForToday() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return (startOfDay, endOfDay(from: startOfDay))
    }

    /// Returns date range for the last N days including today
    static func dateRangeForLastDays(_ days: Int) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let end = endOfDay(from: startOfToday)
        let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: startOfToday) ?? startOfToday
        return (startDate, end)
    }

    /// Returns date range for a specific date
    static func dateRangeForDate(_ date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return (startOfDay, endOfDay(from: startOfDay))
    }

    /// Creates a predicate for date range
    /// Uses empty options to include samples that overlap the range (important for overnight sleep)
    static func predicateForDateRange(start: Date, end: Date) -> NSPredicate {
        return HKQuery.predicateForSamples(withStart: start, end: end, options: [])
    }

    // MARK: - Query Building

    /// Creates a statistics query for a quantity type
    static func statisticsQuery(
        for quantityType: HKQuantityType,
        start: Date,
        end: Date,
        options: HKStatisticsOptions,
        completion: @escaping (HKStatistics?, Error?) -> Void
    ) -> HKStatisticsQuery {
        let predicate = predicateForDateRange(start: start, end: end)
        return HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: options
        ) { _, statistics, error in
            completion(statistics, error)
        }
    }

    /// Creates a statistics collection query for daily aggregation
    static func statisticsCollectionQuery(
        for quantityType: HKQuantityType,
        start: Date,
        end: Date,
        anchorDate: Date,
        intervalComponents: DateComponents,
        options: HKStatisticsOptions,
        completion: @escaping (HKStatisticsCollection?, Error?) -> Void
    ) -> HKStatisticsCollectionQuery {
        let predicate = predicateForDateRange(start: start, end: end)
        return HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: options,
            anchorDate: anchorDate,
            intervalComponents: intervalComponents
        )
    }

    /// Creates a sample query for the most recent sample
    static func mostRecentSampleQuery(
        for sampleType: HKSampleType,
        completion: @escaping ([HKSample]?, Error?) -> Void
    ) -> HKSampleQuery {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        return HKSampleQuery(
            sampleType: sampleType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            completion(samples, error)
        }
    }

    /// Creates a sample query for a date range
    static func sampleQuery(
        for sampleType: HKSampleType,
        start: Date,
        end: Date,
        limit: Int = HKObjectQueryNoLimit,
        completion: @escaping ([HKSample]?, Error?) -> Void
    ) -> HKSampleQuery {
        let predicate = predicateForDateRange(start: start, end: end)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        return HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            completion(samples, error)
        }
    }

    /// Creates an anchored object query for real-time updates
    static func anchoredObjectQuery(
        for sampleType: HKSampleType,
        anchor: HKQueryAnchor?,
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void,
        updateHandler: @escaping (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void
    ) -> HKAnchoredObjectQuery {
        let query = HKAnchoredObjectQuery(
            type: sampleType,
            predicate: nil,
            anchor: anchor,
            limit: limit,
            resultsHandler: resultsHandler
        )
        query.updateHandler = updateHandler
        return query
    }

    // MARK: - Helper Functions

    /// Get daily interval components
    static func dailyIntervalComponents() -> DateComponents {
        var components = DateComponents()
        components.day = 1
        return components
    }

    /// Get anchor date at midnight
    static func anchorDateAtMidnight() -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date())
    }
}
