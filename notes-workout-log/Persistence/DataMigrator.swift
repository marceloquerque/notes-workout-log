//
//  DataMigrator.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import Foundation
import SwiftData
import OSLog

/// Handles one-time migration from UserDefaults (legacy) to SwiftData
enum DataMigrator {
    private static let logger = Logger(subsystem: "com.notes-workout-log", category: "DataMigrator")
    
    private static let didMigrateKey = "didMigrateToSwiftData"
    private static let savedFoldersKey = "savedFolders"
    private static let savedNotesKey = "savedNotes"
    
    // MARK: - Legacy Models (for decoding UserDefaults JSON)
    
    private struct LegacyFolder: Codable {
        let id: UUID
        var name: String
        let isSystemFolder: Bool
    }
    
    private struct LegacyNote: Codable {
        let id: UUID
        var content: String
        let folderId: UUID
        let sortDate: Date
        let createdDate: Date
    }
    
    // MARK: - Migration
    
    static func migrateIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: didMigrateKey) else {
            logger.debug("Migration already completed, skipping")
            return
        }
        
        logger.info("Starting UserDefaults → SwiftData migration")
        
        do {
            try performMigration(context: context)
            UserDefaults.standard.set(true, forKey: didMigrateKey)
            clearLegacyData()
            logger.info("Migration completed successfully")
        } catch {
            logger.error("Migration failed: \(error.localizedDescription)")
            // Don't mark as migrated on failure - will retry next launch
        }
    }
    
    private static func performMigration(context: ModelContext) throws {
        // Decode legacy data
        let legacyFolders = decodeLegacyFolders()
        let legacyNotes = decodeLegacyNotes()
        
        guard !legacyFolders.isEmpty || !legacyNotes.isEmpty else {
            logger.info("No legacy data to migrate")
            return
        }
        
        logger.info("Migrating \(legacyFolders.count) folders and \(legacyNotes.count) notes")
        
        // Create folders first, keeping track of ID → Folder mapping
        var folderMap: [UUID: Folder] = [:]
        
        for legacy in legacyFolders {
            let folder = Folder(
                id: legacy.id,
                name: legacy.name,
                isSystemFolder: legacy.isSystemFolder
            )
            context.insert(folder)
            folderMap[legacy.id] = folder
        }
        
        // Ensure default folder exists for orphaned notes
        let defaultFolder: Folder
        if let existing = folderMap.values.first {
            defaultFolder = existing
        } else {
            defaultFolder = Folder(name: "Notes")
            context.insert(defaultFolder)
        }
        
        // Create notes with relationships
        for legacy in legacyNotes {
            let folder = folderMap[legacy.folderId] ?? defaultFolder
            let note = Note(
                id: legacy.id,
                content: legacy.content,
                folder: folder,
                createdAt: legacy.sortDate,  // sortDate → createdAt (never changes)
                updatedAt: legacy.createdDate
            )
            context.insert(note)
        }
        
        try context.save()
    }
    
    private static func decodeLegacyFolders() -> [LegacyFolder] {
        guard let data = UserDefaults.standard.data(forKey: savedFoldersKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([LegacyFolder].self, from: data)
        } catch {
            logger.warning("Failed to decode legacy folders: \(error.localizedDescription)")
            return []
        }
    }
    
    private static func decodeLegacyNotes() -> [LegacyNote] {
        guard let data = UserDefaults.standard.data(forKey: savedNotesKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([LegacyNote].self, from: data)
        } catch {
            logger.warning("Failed to decode legacy notes: \(error.localizedDescription)")
            return []
        }
    }
    
    private static func clearLegacyData() {
        UserDefaults.standard.removeObject(forKey: savedFoldersKey)
        UserDefaults.standard.removeObject(forKey: savedNotesKey)
        logger.debug("Cleared legacy UserDefaults data")
    }
}

