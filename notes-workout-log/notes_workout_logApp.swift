//
//  notes_workout_logApp.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI
import SwiftData

private enum InitializationState {
    case success(container: ModelContainer, store: NotesStore)
    case failure(Error)
}

@main
struct notes_workout_logApp: App {
    private let state: InitializationState
    
    init() {
        do {
            let schema = Schema([Folder.self, Note.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            let store = NotesStore(modelContext: container.mainContext)
            state = .success(container: container, store: store)
        } catch {
            state = .failure(error)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            switch state {
            case .success(let container, let store):
                ContentView()
                    .environment(store)
                    .modelContainer(container)
            case .failure(let error):
                DatabaseErrorView(error: error)
            }
        }
    }
}
