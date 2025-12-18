//
//  NoteEditorViewModel.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import Foundation
import SwiftUI

@Observable
final class NoteEditorViewModel {
    var note: Note
    var content: String
    
    private let notesViewModel: NotesViewModel
    
    var title: String {
        let lines = content.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespaces) ?? ""
        return firstLine.isEmpty ? "New Note" : firstLine
    }
    
    init(note: Note, notesViewModel: NotesViewModel) {
        self.note = note
        self.content = note.content
        self.notesViewModel = notesViewModel
    }
    
    func save() {
        var updatedNote = note
        updatedNote.content = content
        notesViewModel.updateNote(updatedNote)
        note = updatedNote
    }
}
