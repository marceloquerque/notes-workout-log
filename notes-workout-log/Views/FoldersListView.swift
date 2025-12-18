//
//  FoldersListView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI
import SwiftData

struct FoldersListView: View {
    @Environment(NotesStore.self) private var store
    @Query(sort: \Folder.createdAt) private var folders: [Folder]
    @State private var showFolderCreation = false
    @State private var searchText: String = ""
    @State private var navigationPath = NavigationPath()
    
    private var filteredFolders: [Folder] {
        if searchText.isEmpty {
            return folders
        }
        return folders.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if filteredFolders.isEmpty && !searchText.isEmpty {
                    EmptyStateView(message: "No Folders")
                } else if folders.isEmpty {
                    EmptyStateView(message: "No Folders")
                } else {
                    List {
                        Section("On My iPhone") {
                            ForEach(filteredFolders) { folder in
                                NavigationLink(value: folder) {
                                    FolderRow(folder: folder)
                                }
                            }
                            .onDelete(perform: deleteFolders)
                        }
                    }
                }
            }
            .navigationTitle("Folders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFolderCreation = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Button {
                            if let defaultFolder = folders.first,
                               let note = store.createNote(in: defaultFolder) {
                                navigationPath.append(note)
                            }
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .disabled(folders.isEmpty)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .sheet(isPresented: $showFolderCreation) {
                FolderCreationView()
            }
            .navigationDestination(for: Folder.self) { folder in
                NotesListView(folder: folder)
            }
            .navigationDestination(for: Note.self) { note in
                NoteEditorView(note: note)
            }
        }
    }
    
    private func deleteFolders(at offsets: IndexSet) {
        for index in offsets {
            store.deleteFolder(filteredFolders[index])
        }
    }
}

private struct FolderRow: View {
    let folder: Folder
    
    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
                .foregroundStyle(.yellow)
            Text(folder.name)
            Spacer()
            Text("\(folder.notes.count)")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
    }
}

#Preview {
    FoldersListView()
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
        .environment(NotesStore(modelContext: ModelContext(try! ModelContainer(for: Folder.self, Note.self))))
}
