//
//  Note.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import Foundation

struct Note: Identifiable, Codable, Hashable {
    let id: UUID
    var content: String
    let folderId: UUID
    let sortDate: Date
    let createdDate: Date
    
    var title: String {
        let lines = content.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespaces) ?? ""
        return firstLine.isEmpty ? "New Note" : firstLine
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
    
    init(id: UUID = UUID(), content: String = "", folderId: UUID, sortDate: Date? = nil, createdDate: Date? = nil) {
        self.id = id
        self.content = content
        self.folderId = folderId
        self.sortDate = sortDate ?? Date()
        self.createdDate = createdDate ?? Date()
    }
}
