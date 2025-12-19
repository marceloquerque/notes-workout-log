---
name: Editable note title (stored)
overview: Make note titles editable directly in the navigation bar (long press), stored independently from body content. Update list/search/preview and persistence accordingly; user will reset data by deleting the app (no migration).
todos:
  - id: model_title_field
    content: Add stored `title` field to `Note` model. Replace computed `title` with `displayTitle` computed property. Update `preview` to derive from content lines (no longer skip first line). Update initializer.
    status: completed
  - id: store_title_api
    content: Add `updateNoteTitle(_:title:)` method to `NotesStore`. Update `createNote(in:)` to initialize with empty title. Update logging to use `displayTitle`.
    status: completed
    dependencies:
      - model_title_field
  - id: editor_nav_title
    content: "Implement editable nav title in `NoteEditorView`: add state for `titleDraft`, `isEditingTitle`, `titleFieldFocused`. Replace `.navigationTitle` with custom principal toolbar item (Text when not editing, TextField when editing). Add long press gesture to enter edit mode. Implement `commitTitle()` that saves via store. Save title on Back button and `onDisappear`."
    status: completed
    dependencies:
      - store_title_api
  - id: list_search_title
    content: "Update `NotesListView`: change row title to use `note.displayTitle`. Update search filter to search both `note.title` and `note.content`."
    status: completed
    dependencies:
      - model_title_field
  - id: disable_legacy_migrator
    content: Remove `DataMigrator.migrateIfNeeded(...)` call from `notes_workout_logApp.swift` init.
    status: completed
  - id: tests_update
    content: Update `testNoteTitle()` test to verify stored title behavior. Add tests for `displayTitle` default, title/content independence, and updated `preview` logic.
    status: completed
    dependencies:
      - model_title_field
      - store_title_api
---

# Editable Note Title (Stored)

## Goal

Let users edit the note title directly in the navigation bar (entered via **long press**), with title persisted **independently** from body content. Preserve the Apple Notes feel (inline nav title, same hierarchy, minimal chrome).

## Key Decisions (confirmed)

- **Storage**: Add a **stored** `title` field on `Note` (not derived from `content`).
- **Edit affordance**: **Long press** on the nav title to enter edit mode.
- **Sync**: **No auto-sync** from content's first line → title.
- **Default title**: Display **"New Note"** when `title` is empty.
- **Finish editing**: **Keyboard submit** ends editing; keep the ellipsis menu visible.
- **Leaving without submit**: **Save title draft on Back / onDisappear**.
- **Migration**: **No migration**; user will **delete app** to reset data after the model change.

## Why the previous plan was inaccurate

The prior plan proposed rewriting the first line of `content`. That conflicts with your intent ("title not derived from content") and would desync:

- `NotesListView` display/search (currently based on `note.title`)
- computed `preview` (currently assumes line 1 is title and skips it)

## Implementation Plan

### 1) Update the data model

**File**: [`notes-workout-log/Models/Note.swift`](notes-workout-log/Models/Note.swift)

- Add stored `var title: String`
- Replace the computed `title` currently derived from `content`
- Add computed `var displayTitle: String`:
- returns `AppStrings.newNoteTitle` when `title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty`
- otherwise returns trimmed `title`
- Update `preview` to no longer skip the first line (because title is no longer inside `content`):
- build preview from the first 1–2 non-empty trimmed lines of `content`
- Update initializer defaults (e.g. `title: ""`, `content: ""`).

### 2) Update persistence/store operations

**File**: [`notes-workout-log/Persistence/NotesStore.swift`](notes-workout-log/Persistence/NotesStore.swift)

- Update `createNote(in:)` to create `Note(title: "", content: "", folder: ...)`.
- Add `updateNoteTitle(_ note: Note, title: String)` that sets `note.title` and bumps `updatedAt`.
- Update logging or UI strings to prefer `note.displayTitle` where appropriate.

### 3) Make the nav title editable via long press

**File**: [`notes-workout-log/Views/NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift)

- Remove the view-local computed `title` derived from `content`.
- Add state:
- `@State private var titleDraft: String` (initialized from `note.title`)
- `@State private var isEditingTitle: Bool = false`
- `@FocusState private var titleFieldFocused: Bool`
- Replace `.navigationTitle(title)` with a custom principal toolbar title:
- When not editing: show `Text(note.displayTitle)`; attach `.onLongPressGesture { isEditingTitle = true; titleDraft = note.title; focus }`
- When editing: show `TextField(AppStrings.newNoteTitle, text: $titleDraft)` in the principal area
    - `.submitLabel(.done)` and `.onSubmit { commitTitle(); isEditingTitle = false }`
- Save behavior:
- On Back button: call `commitTitle()` before dismiss (in addition to existing content save)
- On `onDisappear`: call `commitTitle()` (after cancelling tasks), then save
- `commitTitle()` uses `store.updateNoteTitle(note, title: titleDraft)` and `store.save()` (or defers save until existing save path, but must persist reliably)

### 4) Update notes list display + search

**File**: [`notes-workout-log/Views/NotesListView.swift`](notes-workout-log/Views/NotesListView.swift)

- Update row title `Text(note.title)` → `Text(note.displayTitle)`.
- Update search filter to use title field (and optionally displayTitle):
- `note.title.localizedCaseInsensitiveContains(searchText)` (or `note.displayTitle...`) plus `note.content...`.

### 5) Disable legacy UserDefaults migration (since we're wiping data)

**File**: [`notes-workout-log/notes_workout_logApp.swift`](notes-workout-log/notes_workout_logApp.swift)

- Remove the call to `DataMigrator.migrateIfNeeded(...)` to avoid maintaining legacy decode paths during a wipe-data phase.

### 6) Update unit tests

**File**: [`notes-workout-logTests/NotesStoreTests.swift`](notes-workout-logTests/NotesStoreTests.swift)

- Replace `testNoteTitle()` expectations (no longer derived from content).
- Add tests for:
- default `displayTitle == "New Note"` when `title` empty
- updating `title` does not change `content`
- `preview` derived from `content` lines (no skipping)

## Manual Reset Instruction (required for this iteration)

After installing a build with the new `Note.title` field, **delete the app** from the simulator/device to clear the old SwiftData store.

## Implementation Todos

- `model_title_field`: Add stored `title` + `displayTitle`; update `preview` semantics in `Note`
- `store_title_api`: Add title update API and adjust create/logging in `NotesStore`
- `editor_nav_title`: Implement long-press-to-edit nav title (principal toolbar) + save-on-back/disappear
- `list_search_title`: Update `NotesListView` row + search to use stored title