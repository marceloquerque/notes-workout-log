//
//  Note.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import Foundation
import SwiftData

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    var folder: Folder?
    
    var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? AppStrings.newNoteTitle : trimmed
    }
    
    var preview: String {
        let lines = content.components(separatedBy: .newlines)
        let previewLines = lines.prefix(2)
        return previewLines
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        folder: Folder? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.folder = folder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
