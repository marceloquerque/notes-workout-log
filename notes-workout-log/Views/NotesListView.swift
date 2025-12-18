//
//  NotesListView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI

struct NotesListView: View {
    let folder: Folder
    let foldersViewModel: FoldersViewModel
    let notesViewModel: NotesViewModel
    @State private var searchText: String = ""
    @State private var newNoteToEdit: Note?
    
    var body: some View {
        Group {
            if notesViewModel.filteredNotes.isEmpty {
                EmptyStateView(message: "No Notes")
            } else {
                notesList
            }
        }
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        // Delete action - handled by swipe
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(true)
                    
                    Button {
                        // Copy action placeholder
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .disabled(true)
                    
                    Button {
                        // Create Folder - navigate back to folders list
                    } label: {
                        Label("Create Folder", systemImage: "folder.badge.plus")
                    }
                    .disabled(true)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                    Button {
                        notesViewModel.loadNotes(for: folder.id)
                        let note = notesViewModel.createNote()
                        newNoteToEdit = note
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: searchText) { oldValue, newValue in
            notesViewModel.searchText = newValue
        }
        .onAppear {
            notesViewModel.loadNotes(for: folder.id)
        }
        .navigationDestination(for: Note.self) { note in
            NoteEditorView(note: note, folderName: folder.name, notesViewModel: notesViewModel)
        }
        .navigationDestination(item: $newNoteToEdit) { note in
            NoteEditorView(note: note, folderName: folder.name, notesViewModel: notesViewModel)
        }
    }
    
    private var notesList: some View {
        List {
            ForEach(notesViewModel.sortedMonthKeys, id: \.self) { monthKey in
                Section(monthKey) {
                    notesSection(for: monthKey)
                }
            }
        }
    }
    
    @ViewBuilder
    private func notesSection(for monthKey: String) -> some View {
        if let monthNotes = notesViewModel.groupedNotes[monthKey] {
            ForEach(monthNotes) { note in
                noteRow(note)
            }
            .onDelete { indexSet in
                deleteNotes(monthNotes: monthNotes, at: indexSet)
            }
        }
    }
    
    private func noteRow(_ note: Note) -> some View {
        NavigationLink(value: note) {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                HStack {
                    Text(formatDate(note.sortDate))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if !note.preview.isEmpty {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(note.preview)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
    
    private func deleteNotes(monthNotes: [Note], at indexSet: IndexSet) {
        for index in indexSet {
            notesViewModel.deleteNote(monthNotes[index])
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        NotesListView(
            folder: Folder(name: "Notes"),
            foldersViewModel: FoldersViewModel(),
            notesViewModel: NotesViewModel()
        )
    }
}

