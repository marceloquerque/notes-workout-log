//
//  AppConstants.swift
//  notes-workout-log
//
//  Centralized constants for strings, date formats, and app identifiers.
//

import Foundation

// MARK: - App Identifiers

enum AppIdentifiers {
    static let loggerSubsystem = "com.notes-workout-log"
}

// MARK: - Date Formats

enum AppDateFormats {
    /// Month name format (e.g., "December")
    static let monthName = "MMMM"
    /// Note row date format (e.g., "18/12/25")
    static let noteRowDate = "dd/MM/yy"
}

// MARK: - User-Facing Strings

enum AppStrings {

    // MARK: Common
    static let ok = "OK"
    static let cancel = "Cancel"
    static let create = "Create"
    static let delete = "Delete"
    static let rename = "Rename"
    static let share = "Share"
    static let copy = "Copy"

    // MARK: Notes
    static let newNoteTitle = "New Note"
    static let noNotes = "No Notes"

    // MARK: Folders
    static let defaultFolderName = "Notes"
    static let folders = "Folders"
    static let noFolders = "No Folders"
    static let newFolder = "New Folder"
    static let renameFolder = "Rename Folder"
    static let folderNamePlaceholder = "Folder Name"
    static let createFolder = "Create Folder"
    static let onMyiPhone = "On My iPhone"

    // MARK: Templates
    static let templates = "Templates"

    // MARK: Errors
    enum Errors {
        static let defaultTitle = "Error"
        static let saveFailed = "Failed to save changes"
        static let deleteFailed = "Failed to delete item"
        static let folderRequired = "A folder is required for this action"
        static let unknown = "An unexpected error occurred"

        static let tryAgainSuggestion = "Please try again. If the problem persists, restart the app."
        static let selectFolderSuggestion = "Select or create a folder first."
    }
}

