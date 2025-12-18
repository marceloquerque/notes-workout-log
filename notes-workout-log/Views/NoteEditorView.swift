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
    
    init(note: Note, notesViewModel: NotesViewModel) {
        self.notesViewModel = notesViewModel
        self._viewModel = State(initialValue: NoteEditorViewModel(note: note, notesViewModel: notesViewModel))
    }
    
    var body: some View {
        TextEditor(text: $viewModel.content)
            .padding(.horizontal)
            .autocorrectionDisabled()
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.save()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(10)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
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
            notesViewModel: NotesViewModel()
        )
    }
}

