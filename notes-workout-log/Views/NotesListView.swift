//
//  NotesListView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI
import SwiftData

struct NotesListView: View {
    @Environment(NotesStore.self) private var store
    @Query private var notes: [Note]
    
    let folder: Folder
    @Binding var activeComposeFolder: Folder?
    @State private var searchText: String = ""
    
    init(folder: Folder, activeComposeFolder: Binding<Folder?>) {
        self.folder = folder
        self._activeComposeFolder = activeComposeFolder
        let folderId = folder.id
        _notes = Query(
            filter: #Predicate<Note> { note in
                note.folder?.id == folderId
            },
            sort: [SortDescriptor(\Note.createdAt, order: .reverse)]
        )
    }
    
    private var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        }
        return notes.filter { note in
            note.displayTitle.localizedCaseInsensitiveContains(searchText) ||
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var groupedNotes: [String: [Note]] {
        let formatter = DateFormatter()
        formatter.dateFormat = AppDateFormats.monthName
        
        var grouped: [String: [Note]] = [:]
        for note in filteredNotes {
            let monthKey = formatter.string(from: note.createdAt)
            grouped[monthKey, default: []].append(note)
        }
        return grouped
    }
    
    private var sortedMonthKeys: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = AppDateFormats.monthName
        
        let uniqueMonths = Set(filteredNotes.map { formatter.string(from: $0.createdAt) })
        return uniqueMonths.sorted { month1, month2 in
            guard let date1 = formatter.date(from: month1),
                  let date2 = formatter.date(from: month2) else {
                return month1 < month2
            }
            return date1 > date2
        }
    }
    
    var body: some View {
        Group {
            if filteredNotes.isEmpty {
                EmptyStateView(message: AppStrings.noNotes)
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
                        Label(AppStrings.delete, systemImage: "trash")
                    }
                    .disabled(true)
                    
                    Button {
                        // Copy action placeholder
                    } label: {
                        Label(AppStrings.copy, systemImage: "doc.on.doc")
                    }
                    .disabled(true)
                    
                    Button {
                        // Create Folder - navigate back to folders list
                    } label: {
                        Label(AppStrings.createFolder, systemImage: "folder.badge.plus")
                    }
                    .disabled(true)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onAppear {
            activeComposeFolder = folder
        }
        .onDisappear {
            if activeComposeFolder?.id == folder.id {
                activeComposeFolder = nil
            }
        }
    }
    
    private var notesList: some View {
        List {
            ForEach(sortedMonthKeys, id: \.self) { monthKey in
                Section(monthKey) {
                    notesSection(for: monthKey)
                }
            }
        }
    }
    
    @ViewBuilder
    private func notesSection(for monthKey: String) -> some View {
        if let monthNotes = groupedNotes[monthKey] {
            ForEach(monthNotes) { note in
                NoteRow(note: note)
            }
            .onDelete { indexSet in
                deleteNotes(monthNotes: monthNotes, at: indexSet)
            }
        }
    }
    
    private func deleteNotes(monthNotes: [Note], at indexSet: IndexSet) {
        for index in indexSet {
            store.deleteNote(monthNotes[index])
        }
    }
}

private struct NoteRow: View {
    let note: Note
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = AppDateFormats.noteRowDate
        return formatter
    }()
    
    var body: some View {
        NavigationLink(value: note) {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.displayTitle)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Text(Self.dateFormatter.string(from: note.createdAt))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if !note.preview.isEmpty {
                        Text(note.preview)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var activeComposeFolder: Folder?
    NavigationStack {
        NotesListView(folder: Folder(name: AppStrings.defaultFolderName), activeComposeFolder: $activeComposeFolder)
            .modelContainer(for: [Folder.self, Note.self], inMemory: true)
            .environment(NotesStore(modelContext: ModelContext(try! ModelContainer(for: Folder.self, Note.self))))
    }
}
