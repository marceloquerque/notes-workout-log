//
//  NotesStore.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import Foundation
import SwiftData
import OSLog

@Observable
final class NotesStore {
    var alert: AppAlert?
    var searchText: String = ""
    
    private let modelContext: ModelContext
    private let logger = Logger(subsystem: "com.notes-workout-log", category: "NotesStore")
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        ensureDefaultFolderExists()
    }
    
    // MARK: - Folder Operations
    
    @discardableResult
    func createFolder(name: String) -> Folder? {
        let folder = Folder(name: name)
        modelContext.insert(folder)
        
        do {
            try modelContext.save()
            logger.info("Created folder: \(name)")
            return folder
        } catch {
            logger.error("Failed to create folder: \(error.localizedDescription)")
            alert = AppAlert(error: .saveFailed(underlying: error))
            return nil
        }
    }
    
    func deleteFolder(_ folder: Folder) {
        modelContext.delete(folder)
        
        do {
            try modelContext.save()
            logger.info("Deleted folder: \(folder.name)")
        } catch {
            logger.error("Failed to delete folder: \(error.localizedDescription)")
            alert = AppAlert(error: .deleteFailed(underlying: error))
        }
    }
    
    func renameFolder(_ folder: Folder, to newName: String) {
        folder.name = newName
        folder.updatedAt = Date()
        save()
    }
    
    // MARK: - Note Operations
    
    @discardableResult
    func createNote(in folder: Folder) -> Note? {
        let note = Note(folder: folder)
        modelContext.insert(note)
        
        do {
            try modelContext.save()
            logger.info("Created note in folder: \(folder.name)")
            return note
        } catch {
            logger.error("Failed to create note: \(error.localizedDescription)")
            alert = AppAlert(error: .saveFailed(underlying: error))
            return nil
        }
    }
    
    func deleteNote(_ note: Note) {
        modelContext.delete(note)
        
        do {
            try modelContext.save()
            logger.info("Deleted note: \(note.title)")
        } catch {
            logger.error("Failed to delete note: \(error.localizedDescription)")
            alert = AppAlert(error: .deleteFailed(underlying: error))
        }
    }
    
    func updateNoteContent(_ note: Note, content: String) {
        note.content = content
        note.updatedAt = Date()
    }
    
    func moveNote(_ note: Note, to folder: Folder) {
        note.folder = folder
        note.updatedAt = Date()
        save()
    }
    
    // MARK: - Save
    
    func save() {
        guard modelContext.hasChanges else { return }
        
        do {
            try modelContext.save()
            logger.debug("Saved changes")
        } catch {
            logger.error("Failed to save: \(error.localizedDescription)")
            alert = AppAlert(error: .saveFailed(underlying: error))
        }
    }
    
    // MARK: - Private
    
    private func ensureDefaultFolderExists() {
        let descriptor = FetchDescriptor<Folder>()
        
        do {
            let folders = try modelContext.fetch(descriptor)
            if folders.isEmpty {
                let defaultFolder = Folder(name: "Notes")
                modelContext.insert(defaultFolder)
                try modelContext.save()
                logger.info("Created default folder")
            }
        } catch {
            logger.error("Failed to check/create default folder: \(error.localizedDescription)")
        }
    }
}

