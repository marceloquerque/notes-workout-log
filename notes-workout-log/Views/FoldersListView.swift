//
//  FoldersListView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI

struct FoldersListView: View {
    @State private var foldersViewModel = FoldersViewModel()
    @State private var notesViewModel = NotesViewModel()
    @State private var showFolderCreation = false
    @State private var searchText: String = ""
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if foldersViewModel.filteredFolders.isEmpty {
                    EmptyStateView(message: "No Folders")
                } else {
                    List {
                        Section("On My iPhone") {
                            ForEach(foldersViewModel.filteredFolders) { folder in
                                NavigationLink(value: folder) {
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .foregroundStyle(.yellow)
                                        Text(folder.name)
                                        Spacer()
                                        Text("\(notesViewModel.getNoteCount(for: folder.id))")
                                            .foregroundStyle(.secondary)
                                            .font(.subheadline)
                                    }
                                }
                            }
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
                            if let defaultFolder = foldersViewModel.folders.first {
                                notesViewModel.loadNotes(for: defaultFolder.id)
                                let note = notesViewModel.createNote()
                                navigationPath.append(defaultFolder)
                                navigationPath.append(note)
                            }
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .disabled(foldersViewModel.folders.isEmpty)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchText) { oldValue, newValue in
                foldersViewModel.searchText = newValue
            }
            .sheet(isPresented: $showFolderCreation) {
                FolderCreationView(foldersViewModel: foldersViewModel)
            }
            .navigationDestination(for: Folder.self) { folder in
                NotesListView(folder: folder, foldersViewModel: foldersViewModel, notesViewModel: notesViewModel)
            }
            .navigationDestination(for: Note.self) { note in
                if let folder = foldersViewModel.folders.first(where: { $0.id == note.folderId }) {
                    NoteEditorView(note: note, folderName: folder.name, notesViewModel: notesViewModel)
                }
            }
        }
    }
}

#Preview {
    FoldersListView()
}

