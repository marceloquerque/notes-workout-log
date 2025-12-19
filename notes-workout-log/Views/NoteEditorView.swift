//
//  NoteEditorView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI
import SwiftData
import Combine

struct NoteEditorView: View {
    @Environment(NotesStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Bindable var note: Note
    @State private var content: String
    @State private var titleDraft: String
    @State private var isEditingTitle: Bool = false
    @State private var saveTask: Task<Void, Never>?
    @FocusState private var titleFieldFocused: Bool
    
    init(note: Note) {
        self.note = note
        self._content = State(initialValue: note.content)
        self._titleDraft = State(initialValue: note.title)
    }
    
    var body: some View {
        TextEditor(text: $content)
            .padding(.horizontal)
            .autocorrectionDisabled()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        saveImmediately()
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
                ToolbarItem(placement: .principal) {
                    if isEditingTitle {
                        TextField(AppStrings.newNoteTitle, text: $titleDraft)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .submitLabel(.done)
                            .focused($titleFieldFocused)
                            .onSubmit {
                                commitTitle()
                                isEditingTitle = false
                            }
                    } else {
                        Text(displayTitle)
                            .font(.headline)
                            .onLongPressGesture {
                                titleDraft = note.title
                                isEditingTitle = true
                                titleFieldFocused = true
                            }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            store.deleteNote(note)
                            dismiss()
                        } label: {
                            Label(AppStrings.delete, systemImage: "trash")
                        }
                        
                        Button {
                            // Share placeholder
                        } label: {
                            Label(AppStrings.share, systemImage: "square.and.arrow.up")
                        }
                        .disabled(true)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onChange(of: content) { _, newValue in
                scheduleDebouncedSave(newValue)
            }
            .onDisappear {
                saveTask?.cancel()
                saveImmediately()
            }
    }
    
    private var displayTitle: String {
        let trimmed = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? AppStrings.newNoteTitle : trimmed
    }
    
    private func commitTitle() {
        store.updateNoteTitle(note, title: titleDraft)
    }
    
    private func scheduleDebouncedSave(_ newContent: String) {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                store.updateNoteContent(note, content: newContent)
                store.save()
            }
        }
    }
    
    private func saveImmediately() {
        saveTask?.cancel()
        commitTitle()
        store.updateNoteContent(note, content: content)
        store.save()
    }
}

#Preview {
    let container = try! ModelContainer(for: Folder.self, Note.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let folder = Folder(name: AppStrings.defaultFolderName)
    let note = Note(title: "Sample Title", content: "Sample note", folder: folder)
    container.mainContext.insert(folder)
    container.mainContext.insert(note)
    
    return NavigationStack {
        NoteEditorView(note: note)
            .modelContainer(container)
            .environment(NotesStore(modelContext: container.mainContext))
    }
}
