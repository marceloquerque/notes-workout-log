//
//  FolderCreationView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI

struct FolderCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var folderName: String = ""
    let foldersViewModel: FoldersViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Folder Name", text: $folderName)
                    .autocapitalization(.words)
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
                        if !folderName.trimmingCharacters(in: .whitespaces).isEmpty {
                            foldersViewModel.createFolder(name: folderName.trimmingCharacters(in: .whitespaces))
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
    FolderCreationView(foldersViewModel: FoldersViewModel())
}

