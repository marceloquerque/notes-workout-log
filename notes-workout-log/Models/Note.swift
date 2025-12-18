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
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    var folder: Folder?
    
    var title: String {
        let lines = content.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespaces) ?? ""
        return firstLine.isEmpty ? AppStrings.newNoteTitle : firstLine
    }
    
    var preview: String {
        let lines = content.components(separatedBy: .newlines)
        guard lines.count > 1 else { return "" }
        
        let previewLines = Array(lines[1...]).prefix(2)
        return previewLines
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    init(
        id: UUID = UUID(),
        content: String = "",
        folder: Folder? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.folder = folder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
