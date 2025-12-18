//
//  NotesViewModel.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import Foundation
import SwiftUI

@Observable
final class NotesViewModel {
    var notes: [Note] = []
    var currentFolderId: UUID?
    var searchText: String = ""
    
    private let notesKey = "savedNotes"
    
    init() {
        loadNotes()
    }
    
    var filteredNotes: [Note] {
        let folderNotes = notes.filter { $0.folderId == currentFolderId }
        if searchText.isEmpty {
            return folderNotes.sorted { $0.sortDate > $1.sortDate }
        }
        return folderNotes
            .filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { $0.sortDate > $1.sortDate }
    }
    
    var groupedNotes: [String: [Note]] {
        let filtered = filteredNotes
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        
        var grouped: [String: [Note]] = [:]
        for note in filtered {
            let monthKey = formatter.string(from: note.sortDate)
            grouped[monthKey, default: []].append(note)
        }
        
        for key in grouped.keys {
            grouped[key]?.sort { $0.sortDate > $1.sortDate }
        }
        
        return grouped
    }
    
    var sortedMonthKeys: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        
        let uniqueMonths = Set(filteredNotes.map { formatter.string(from: $0.sortDate) })
        let sorted = uniqueMonths.sorted { month1, month2 in
            guard let date1 = formatter.date(from: month1),
                  let date2 = formatter.date(from: month2) else {
                return month1 < month2
            }
            return date1 > date2
        }
        return sorted
    }
    
    func loadNotes(for folderId: UUID) {
        currentFolderId = folderId
    }
    
    func createNote() -> Note {
        guard let folderId = currentFolderId else {
            fatalError("Cannot create note without a folder")
        }
        let note = Note(folderId: folderId)
        notes.append(note)
        saveNotes()
        return note
    }
    
    func updateNote(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else {
            return
        }
        notes[index] = note
        saveNotes()
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    func getNoteCount(for folderId: UUID) -> Int {
        notes.filter { $0.folderId == folderId }.count
    }
    
    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: notesKey),
              let decoded = try? JSONDecoder().decode([Note].self, from: data) else {
            return
        }
        notes = decoded
    }
    
    private func saveNotes() {
        guard let encoded = try? JSONEncoder().encode(notes) else {
            return
        }
        UserDefaults.standard.set(encoded, forKey: notesKey)
    }
}

