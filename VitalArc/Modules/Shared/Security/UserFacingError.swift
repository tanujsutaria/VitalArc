//
//  UserFacingError.swift
//  VitalArc
//
//  Maps internal errors to user-friendly messages without exposing implementation details
//

import Foundation

/// Provides user-friendly error messages that don't expose system details
enum UserFacingError {

    // MARK: - Error Message Mapping

    /// Convert any error to a user-friendly message
    /// Internal details are logged separately (in debug only)
    static func message(for error: Error, context: Context = .general) -> String {
        // Log the full error for debugging (only in debug builds)
        Log.error("User-facing error in \(context.rawValue)", error: error, category: .app)

        // Check for specific error types first
        if let urlError = error as? URLError {
            return message(for: urlError)
        }

        // Return context-appropriate generic message
        return context.genericMessage
    }

    /// URL error messages
    private static func message(for error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet:
            return "No internet connection. Please check your network settings."
        case .timedOut:
            return "The request timed out. Please try again."
        case .cannotFindHost, .cannotConnectToHost:
            return "Unable to reach the server. Please try again later."
        case .networkConnectionLost:
            return "Connection lost. Please try again."
        case .secureConnectionFailed:
            return "Secure connection failed. Please try again."
        default:
            return "A network error occurred. Please try again."
        }
    }

    /// HTTP status code messages
    private static func httpErrorMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 400:
            return "Invalid request. Please check your input."
        case 401, 403:
            return "Access denied. Please check your credentials."
        case 404:
            return "The requested item was not found."
        case 429:
            return "Too many requests. Please wait a moment and try again."
        case 500...599:
            return "Server error. Please try again later."
        default:
            return "An error occurred. Please try again."
        }
    }

    // MARK: - Error Contexts

    enum Context: String {
        case general = "general"
        case loading = "loading"
        case saving = "saving"
        case deleting = "deleting"
        case searching = "searching"
        case syncing = "syncing"
        case exporting = "exporting"

        var genericMessage: String {
            switch self {
            case .general:
                return "Something went wrong. Please try again."
            case .loading:
                return "Failed to load data. Please try again."
            case .saving:
                return "Failed to save. Please try again."
            case .deleting:
                return "Failed to delete. Please try again."
            case .searching:
                return "Search failed. Please try again."
            case .syncing:
                return "Sync failed. Please try again."
            case .exporting:
                return "Export failed. Please try again."
            }
        }
    }
}
