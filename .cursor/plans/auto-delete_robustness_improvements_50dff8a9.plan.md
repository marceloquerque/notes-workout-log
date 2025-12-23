---
name: Auto-delete robustness improvements
overview: "Address forensic analysis findings: add crash-safe cleanup on app launch, improve template insertion safety with defer, and document design decisions."
todos:
  - id: add-cleanup-method
    content: Add cleanupEmptyNotes() method to NotesStore that finds and deletes notes with empty content and title
    status: completed
  - id: call-cleanup-on-launch
    content: Call cleanupEmptyNotes() in NotesStore.init() after ensureDefaultFolderExists()
    status: completed
  - id: add-defer-safety
    content: Wrap insertTemplate() logic with defer { isApplyingTemplate = false } for guaranteed cleanup
    status: completed
  - id: document-draftnoteid
    content: Add comment explaining UUID gating design decision in ContentView
    status: completed
  - id: document-edit-tracking
    content: Add comments explaining edit-tracking logic and shouldDeleteNote rules in NoteEditorView
    status: completed
---

# Auto-delete Robustness Improvements

## Overview

Address critical edge cases identified in forensic code review: handle app crashes gracefully, improve template insertion safety, and document design decisions.

## Implementation Details

### 1. Add Crash-Safe Cleanup on App Launch

**Problem:** If the app crashes or is force-killed while editing a compose-created note, `onDisappear` never fires, leaving empty notes permanently in the database.**Solution:** Add cleanup logic that runs on app launch to remove any empty notes that slipped through.**Changes to [`notes-workout-log/Persistence/NotesStore.swift`](notes-workout-log/Persistence/NotesStore.swift):**

- Add `cleanupEmptyNotes()` method that:
- Fetches all notes
- Checks if `content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty` AND `title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty`
- Deletes matching notes
- Saves the context
- Logs the cleanup operation
- Call `cleanupEmptyNotes()` in `init()` after `ensureDefaultFolderExists()`

**Rationale:** This matches iOS Notes behavior—empty drafts don't survive app termination. The cleanup runs once per app launch, ensuring no orphaned empty notes accumulate.

### 2. Improve Template Insertion Safety with `defer`

**Problem:** The `isApplyingTemplate` flag could theoretically have race conditions if `onChange` closures execute asynchronously.**Solution:** Use Swift's `defer` statement to guarantee the flag is reset even if an early return or exception occurs.**Changes to [`notes-workout-log/Views/NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift):**

- Wrap `insertTemplate(_:)` logic with `defer { isApplyingTemplate = false }`
- This ensures the flag is always reset, even if an error occurs mid-execution

**Rationale:** Defensive programming—while the current implementation is likely safe (state changes are synchronous on main actor), `defer` provides a guarantee that matches the intent.

### 3. Add Documentation Comments

**Problem:** Design decisions around UUID gating and edit-tracking logic are not documented, making the code harder to maintain.**Solution:** Add strategic comments explaining the "why" behind key decisions.**Changes to [`notes-workout-log/ContentView.swift`](notes-workout-log/ContentView.swift):**

- Add comment above `draftNoteID` explaining:
- Why UUID tracking instead of a model property (session-only, avoids schema pollution)
- That draft status is lost on app termination (by design, matching iOS Notes)
- That `cleanupEmptyNotes()` handles orphaned drafts

**Changes to [`notes-workout-log/Views/NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift):**

- Add comment above `didEditAfterTemplateInsert` explaining:
- Once set to `true`, it stays `true` (user-specified requirement)
- This means edit-then-revert still saves the note (intentional UX)
- Add comment above `shouldDeleteNote` explaining:
- Only applies to compose-created notes (prevents accidental deletion of existing notes)
- Two deletion rules: empty-note rule and template-unchanged rule
- Add comment in `onDisappear` explaining:
- Why cleanup happens here (matches iOS Notes "ghost row" animation)
- That `cleanupEmptyNotes()` provides crash safety

## Files to Modify

- [`notes-workout-log/Persistence/NotesStore.swift`](notes-workout-log/Persistence/NotesStore.swift) - Add `cleanupEmptyNotes()` method and call it in `init()`
- [`notes-workout-log/Views/NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift) - Add `defer` to `insertTemplate()` and documentation comments
- [`notes-workout-log/ContentView.swift`](notes-workout-log/ContentView.swift) - Add documentation comment for `draftNoteID`

## Testing Considerations

- App launch with existing empty notes → should clean them up
- App crash during note editing → empty note should be cleaned up on next launch