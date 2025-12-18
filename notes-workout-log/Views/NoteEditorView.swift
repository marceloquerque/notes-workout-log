//
//  NoteEditorView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI

struct NoteEditorView: View {
    @State private var viewModel: NoteEditorViewModel
    @Environment(\.dismiss) private var dismiss
    let notesViewModel: NotesViewModel
    let folderName: String
    
    init(note: Note, folderName: String, notesViewModel: NotesViewModel) {
        self.folderName = folderName
        self.notesViewModel = notesViewModel
        self._viewModel = State(initialValue: NoteEditorViewModel(note: note, notesViewModel: notesViewModel))
    }
    
    var body: some View {
        TextEditor(text: $viewModel.content)
            .padding(.horizontal)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.save()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text(folderName)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            notesViewModel.deleteNote(viewModel.note)
                            dismiss()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            // Share placeholder
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .disabled(true)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onDisappear {
                viewModel.save()
            }
    }
}

#Preview {
    NavigationStack {
        NoteEditorView(
            note: Note(content: "Sample note", folderId: UUID()),
            folderName: "Notes",
            notesViewModel: NotesViewModel()
        )
    }
}

