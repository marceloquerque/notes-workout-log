//
//  ContentView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI
import SwiftData

enum RootTab: String, CaseIterable, Hashable {
    case logbook = "Logbook"
    case calendar = "Calendar"
}

struct ContentView: View {
    @Environment(NotesStore.self) private var store
    @Query(sort: \Folder.createdAt) private var folders: [Folder]
    @State private var tab: RootTab = .logbook
    @State private var navigationPath = NavigationPath()
    @State private var activeComposeFolder: Folder?
    @State private var isEditingNote: Bool = false
    /// Tracks the note created via Compose button for auto-deletion logic.
    /// Uses session-only UUID tracking (not persisted in model) to avoid schema pollution.
    /// Draft status is intentionally lost on app termination (matching iOS Notes behavior).
    /// NotesStore.cleanupEmptyNotes() handles orphaned empty drafts on next cold start.
    @State private var draftNoteID: UUID?
    
    private var defaultFolder: Folder? {
        folders.first(where: { $0.isSystemFolder }) ?? folders.first
    }
    
    var body: some View {
        @Bindable var store = store
        
        ZStack(alignment: .bottomTrailing) {
            NavigationStack(path: $navigationPath) {
                TabView(selection: $tab) {
                    FoldersListView(navigationPath: $navigationPath)
                        .tag(RootTab.logbook)
                    
                    CalendarView()
                        .tag(RootTab.calendar)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker("Tab", selection: $tab) {
                            ForEach(RootTab.allCases, id: \.self) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Folder.self) { folder in
                    NotesListView(folder: folder, activeComposeFolder: $activeComposeFolder)
                }
                .navigationDestination(for: Note.self) { note in
                    NoteEditorView(
                        note: note,
                        isEditingNote: $isEditingNote,
                        isComposeDraft: note.id == draftNoteID,
                        draftNoteID: $draftNoteID
                    )
                }
            }
            
            FloatingComposeButton(
                onCompose: composeNote,
                isEnabled: !folders.isEmpty,
                isVisible: !isEditingNote
            )
            .padding(.trailing, 20)
            .padding(.bottom, 20)
            .safeAreaPadding(.bottom)
        }
        .alert(
            item: $store.alert
        ) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text(AppStrings.ok))
            )
        }
    }
    
    private func composeNote() {
        let targetFolder = activeComposeFolder ?? defaultFolder
        guard let folder = targetFolder,
              let note = store.createNote(in: folder) else { return }
        draftNoteID = note.id
        navigationPath.append(note)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
        .environment(NotesStore(modelContext: ModelContext(try! ModelContainer(for: Folder.self, Note.self))))
}
