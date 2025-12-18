//
//  AppError.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import Foundation

enum AppError: LocalizedError {
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case folderRequired
    case unknown(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save changes"
        case .deleteFailed:
            return "Failed to delete item"
        case .folderRequired:
            return "A folder is required for this action"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .deleteFailed, .unknown:
            return "Please try again. If the problem persists, restart the app."
        case .folderRequired:
            return "Select or create a folder first."
        }
    }
}

struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    
    init(error: AppError) {
        self.title = error.errorDescription ?? "Error"
        self.message = error.recoverySuggestion ?? ""
    }
    
    init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}

