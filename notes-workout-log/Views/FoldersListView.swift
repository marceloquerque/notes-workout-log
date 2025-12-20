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
    @Binding var navigationPath: NavigationPath
    @State private var showFolderCreation = false
    @State private var searchText: String = ""
    @State private var folderToDelete: Folder?
    @State private var folderToRename: Folder?
    @State private var renameText: String = ""
    @State private var isRenameAlertPresented = false
    
    private var filteredFolders: [Folder] {
        if searchText.isEmpty {
            return folders
        }
        return folders.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        Group {
            if filteredFolders.isEmpty && !searchText.isEmpty {
                EmptyStateView(message: AppStrings.noFolders)
            } else if folders.isEmpty {
                EmptyStateView(message: AppStrings.noFolders)
            } else {
                List {
                    Section(AppStrings.onMyiPhone) {
                        ForEach(filteredFolders) { folder in
                            NavigationLink(value: folder) {
                                FolderRow(folder: folder)
                            }
                            .contextMenu {
                                if !folder.isSystemFolder {
                                    Button {
                                        renameText = folder.name
                                        folderToRename = folder
                                        isRenameAlertPresented = true
                                    } label: {
                                        Label(AppStrings.rename, systemImage: "pencil")
                                    }
                                    
                                    Divider()
                                    
                                    Button(role: .destructive) {
                                        folderToDelete = folder
                                    } label: {
                                        Label(AppStrings.delete, systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
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
        .confirmationDialog(
            "Delete \(folderToDelete?.name ?? "")?",
            isPresented: Binding(
                get: { folderToDelete != nil },
                set: { if !$0 { folderToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let folder = folderToDelete {
                    store.deleteFolder(folder)
                }
                folderToDelete = nil
            }
        } message: {
            Text("This will delete all \(folderToDelete?.notes.count ?? 0) notes in this folder.")
        }
        .alert(AppStrings.renameFolder, isPresented: $isRenameAlertPresented) {
            TextField(AppStrings.folderNamePlaceholder, text: $renameText)
            Button(AppStrings.cancel, role: .cancel) {
                folderToRename = nil
            }
            Button(AppStrings.rename) {
                let trimmed = renameText.trimmingCharacters(in: .whitespaces)
                if let folder = folderToRename, !trimmed.isEmpty {
                    store.renameFolder(folder, to: trimmed)
                }
                folderToRename = nil
            }
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
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        FoldersListView(navigationPath: $path)
            .modelContainer(for: [Folder.self, Note.self], inMemory: true)
            .environment(NotesStore(modelContext: ModelContext(try! ModelContainer(for: Folder.self, Note.self))))
    }
}
