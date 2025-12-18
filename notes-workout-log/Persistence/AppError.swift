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
            return AppStrings.Errors.saveFailed
        case .deleteFailed:
            return AppStrings.Errors.deleteFailed
        case .folderRequired:
            return AppStrings.Errors.folderRequired
        case .unknown:
            return AppStrings.Errors.unknown
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .deleteFailed, .unknown:
            return AppStrings.Errors.tryAgainSuggestion
        case .folderRequired:
            return AppStrings.Errors.selectFolderSuggestion
        }
    }
}

struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    
    init(error: AppError) {
        self.title = error.errorDescription ?? AppStrings.Errors.defaultTitle
        self.message = error.recoverySuggestion ?? ""
    }
    
    init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}

