---
name: Auto-delete empty notes
overview: "Auto-delete only compose-created notes when leaving the editor: delete if (1) content is empty AND title is empty/whitespace, or (2) a template was inserted and the user made no changes after insertion."
todos:
  - id: scope-compose-only
    content: Gate auto-delete so it only applies to the compose-created note (avoid deleting existing notes)
    status: completed
  - id: back-button-unify-exit
    content: Remove eager save from custom Back button so Back + swipe-back share the same save-or-delete logic on exit
    status: completed
  - id: track-initial-state
    content: Add state variables to track template insertion snapshot + whether user edited after template insertion
    status: completed
  - id: initialize-on-appear
    content: Initialize compose-draft gating data, and set template snapshot/flags in insertTemplate()
    status: completed
  - id: implement-empty-check
    content: Create shouldDeleteNote computed property that (a) only runs for compose-created notes, (b) deletes truly-empty notes, and (c) deletes template-notes that were never modified after insertion
    status: completed
  - id: add-deletion-logic
    content: Modify onDisappear to check shouldDeleteNote and call store.deleteNote() instead of saveImmediately() when true
    status: completed
---

# Auto-deletion Feature for Empty Notes

## Overview

When a user creates a new note and immediately navigates back without editing, or inserts a template without modifying it, the note should be automatically deleted. The deletion will trigger SwiftUI's built-in list animations, creating a "ghost row" effect where the note briefly appears then slides away.

## Implementation Details

### 0. Scope: compose-created notes only (iOS-like)

Auto-delete must **only** apply to the note created via the Compose button for this navigation session. This prevents accidental deletion of existing notes a user opens from the list and clears.Implement by updating [`ContentView.swift`](notes-workout-log/ContentView.swift):

- Add `@State private var draftNoteID: UUID?`
- In `composeNote()`, after creation: set `draftNoteID = note.id` before pushing the navigation
- In `.navigationDestination(for: Note.self)`, pass `isComposeDraft: (note.id == draftNoteID)` into `NoteEditorView`
- Also pass `draftNoteID` as a binding so `NoteEditorView` can clear it on exit (after save or delete)

### 1. Track Note State in NoteEditorView

Modify [`NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift) to:

- Add inputs:
- `let isComposeDraft: Bool`
- `@Binding var draftNoteID: UUID?` (so we can clear it on exit)
- Add state variables to track the template “unchanged” rule:
- `templateWasInserted: Bool`
- `templateSnapshotTitle: String`
- `templateSnapshotContent: String`
- `didEditAfterTemplateInsert: Bool`
- `isApplyingTemplate: Bool` (prevents the insert itself from counting as an “edit”)

### 2. Implement Empty + Template-Unchanged Check Logic

Add a computed property `shouldDeleteNote` that returns `true` only when `isComposeDraft == true` AND either:

- **Empty-note rule**: `content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty` AND `titleDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty`
- **Template-unchanged rule**: `templateWasInserted == true` AND `didEditAfterTemplateInsert == false` AND `titleDraft == templateSnapshotTitle` AND `content == templateSnapshotContent`

### 3. Track “edited after template”

In `insertTemplate(_:)`:

- Set `isApplyingTemplate = true`
- Apply template (update `titleDraft`, commit title, update `content`)
- Set:
- `templateWasInserted = true`
- `didEditAfterTemplateInsert = false`
- `templateSnapshotTitle = titleDraft`
- `templateSnapshotContent = content`
- Set `isApplyingTemplate = false`

In `onChange(of: content)` and `onChange(of: titleDraft)`:

- If `templateWasInserted && !isApplyingTemplate` and new values differ from the snapshot, set `didEditAfterTemplateInsert = true`

### 4. Auto-delete on Disappear

Modify `onDisappear` in `NoteEditorView` to:

- Cancel `saveTask` first to prevent late saves after leaving
- If `shouldDeleteNote` is true, call `store.deleteNote(note)` and clear `draftNoteID = nil`
- Otherwise, call `saveImmediately()` and clear `draftNoteID = nil`
- The note will be removed from SwiftData context, triggering SwiftUI's automatic list animations

Also update the custom toolbar Back button in `NoteEditorView` to **only** call `dismiss()` (no direct `saveImmediately()`), so swipe-back and button-back share the same exit path.

### 5. Handle Edge Cases

- Ensure `saveTask` is cancelled before delete/save to avoid racing async saves
- Use `store.deleteNote()` which already handles SwiftData context deletion and saving
- The visual "ghost row" effect will occur automatically via SwiftUI's `@Query` updates when the note is deleted from the context

## Data Flow

```mermaid
flowchart TD
    A[User taps Compose] --> B[Note created in NotesStore]
    B --> C[NoteEditorView appears]
    C --> D[Mark_isComposeDraft_true]
    D --> E{User action}
    E -->|Inserts template| F[Snapshot_templateTitleContent]
    E -->|Edits after template| G[didEditAfterTemplateInsert_true]
    E -->|Hits Back| H[onDisappear triggered]
    F --> H
    G --> H
    H --> I{shouldDeleteNote?}
    I -->|Yes| J[Delete note from context]
    I -->|No| K[Save note]
    J --> L[SwiftUI animates removal]
    K --> M[Navigation completes]
    L --> M
```



## Files to Modify

- [`notes-workout-log/ContentView.swift`](notes-workout-log/ContentView.swift) - Track `draftNoteID` and pass compose-draft gating into editor
- [`notes-workout-log/Views/NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift) - Add compose-draft gating, template snapshot tracking, and deletion logic

## Testing Considerations

- Empty note (no content, no title) → should delete
- Note with template but no edits → should delete  
- Note with template and edits → should save
- Note with content but no title → should save