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
                TextField(AppStrings.folderNamePlaceholder, text: $folderName)
                    .textInputAutocapitalization(.words)
            }
            .navigationTitle(AppStrings.newFolder)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppStrings.create) {
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
