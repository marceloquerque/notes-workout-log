//
//  ContentView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(NotesStore.self) private var store
    
    var body: some View {
        @Bindable var store = store
        
        FoldersListView()
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
