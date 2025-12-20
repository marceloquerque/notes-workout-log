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
    @State private var tab: RootTab = .logbook
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        @Bindable var store = store
        
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
                NotesListView(folder: folder)
            }
            .navigationDestination(for: Note.self) { note in
                NoteEditorView(note: note)
            }
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
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
        .environment(NotesStore(modelContext: ModelContext(try! ModelContainer(for: Folder.self, Note.self))))
}
