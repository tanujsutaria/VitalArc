import Foundation

// MARK: - Centralized Strings
//
// This file centralizes user-facing strings for easy localization.
// When localization is implemented, these can be replaced with:
// String(localized: "key", comment: "description")
//
// Usage:
// Text(Strings.Fallback.unknownExercise)

enum Strings {

    // MARK: - Fallback Strings

    enum Fallback {
        /// Displayed when an exercise cannot be found in the database
        static let unknownExercise = String(localized: "Unknown Exercise", comment: "Fallback name when exercise is not found")
    }

    // MARK: - Error Messages

    enum Errors {
        static let networkError = String(localized: "Network error", comment: "Generic network error message")
        static let dataError = String(localized: "Data error", comment: "Generic data error message")
        static let unknownError = String(localized: "An unexpected error occurred", comment: "Generic unknown error message")
    }
}
