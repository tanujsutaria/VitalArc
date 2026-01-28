//
//  Logger.swift
//  VitalArc
//
//  Secure logging utility that only outputs in debug builds
//

import Foundation
import os.log

/// Centralized logging utility that respects build configuration
/// Logs are only output in DEBUG builds to prevent information disclosure
enum Log {

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.vitalarc"

    // MARK: - Log Categories

    private static let appLog = OSLog(subsystem: subsystem, category: "app")
    private static let networkLog = OSLog(subsystem: subsystem, category: "network")
    private static let dataLog = OSLog(subsystem: subsystem, category: "data")
    private static let healthKitLog = OSLog(subsystem: subsystem, category: "healthkit")
    private static let nutritionLog = OSLog(subsystem: subsystem, category: "nutrition")
    private static let workoutLog = OSLog(subsystem: subsystem, category: "workout")

    // MARK: - Public Logging Methods

    /// Log general app messages (only in DEBUG)
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        os_log("[%{public}@:%{public}d] %{public}@", log: appLog, type: .debug, fileName, line, message)
        #endif
    }

    /// Log informational messages (only in DEBUG)
    static func info(_ message: String, category: Category = .app) {
        #if DEBUG
        os_log("%{public}@", log: category.osLog, type: .info, message)
        #endif
    }

    /// Log warnings (only in DEBUG)
    static func warning(_ message: String, category: Category = .app) {
        #if DEBUG
        os_log("[WARNING] %{public}@", log: category.osLog, type: .default, message)
        #endif
    }

    /// Log errors (sanitized in release, full details in debug)
    static func error(_ message: String, error: Error? = nil, category: Category = .app) {
        #if DEBUG
        if let error = error {
            os_log("[ERROR] %{public}@: %{public}@", log: category.osLog, type: .error, message, error.localizedDescription)
        } else {
            os_log("[ERROR] %{public}@", log: category.osLog, type: .error, message)
        }
        #endif
        // In release builds, we intentionally don't log to prevent information disclosure
        // Consider sending to a secure analytics service instead
    }

    /// Log data operations
    static func data(_ message: String) {
        #if DEBUG
        os_log("[Data] %{public}@", log: dataLog, type: .debug, message)
        #endif
    }

    /// Log network operations
    static func network(_ message: String) {
        #if DEBUG
        os_log("[Network] %{public}@", log: networkLog, type: .debug, message)
        #endif
    }

    /// Log HealthKit operations
    static func healthKit(_ message: String) {
        #if DEBUG
        os_log("[HealthKit] %{public}@", log: healthKitLog, type: .debug, message)
        #endif
    }

    /// Log nutrition operations
    static func nutrition(_ message: String) {
        #if DEBUG
        os_log("[Nutrition] %{public}@", log: nutritionLog, type: .debug, message)
        #endif
    }

    /// Log workout operations
    static func workout(_ message: String) {
        #if DEBUG
        os_log("[Workout] %{public}@", log: workoutLog, type: .debug, message)
        #endif
    }

    // MARK: - Categories

    enum Category {
        case app
        case network
        case data
        case healthKit
        case nutrition
        case workout

        var osLog: OSLog {
            switch self {
            case .app: return Log.appLog
            case .network: return Log.networkLog
            case .data: return Log.dataLog
            case .healthKit: return Log.healthKitLog
            case .nutrition: return Log.nutritionLog
            case .workout: return Log.workoutLog
            }
        }
    }
}
