//
//  FolderCreationView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI
import SwiftData

struct FolderCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NotesStore.self) private var store
    @State private var folderName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Folder Name", text: $folderName)
                    .textInputAutocapitalization(.words)
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let trimmed = folderName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            store.createFolder(name: trimmed)
                            dismiss()
                        }
                    }
                    .disabled(folderName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    FolderCreationView()
        .environment(NotesStore(modelContext: ModelContext(try! ModelContainer(for: Folder.self, Note.self))))
}
