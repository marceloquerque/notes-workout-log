//
//  notes_workout_logApp.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI
import SwiftData

@main
struct notes_workout_logApp: App {
    let modelContainer: ModelContainer
    let notesStore: NotesStore
    
    init() {
        do {
            let schema = Schema([Folder.self, Note.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            // Migrate legacy UserDefaults data if needed
            DataMigrator.migrateIfNeeded(context: modelContainer.mainContext)
            
            notesStore = NotesStore(modelContext: modelContainer.mainContext)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(notesStore)
        }
        .modelContainer(modelContainer)
    }
}
