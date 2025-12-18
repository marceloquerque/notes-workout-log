---
name: iOS Notes App MVP
overview: Build a faithful iOS Notes app replica with folders, month-grouped notes list, and auto-title extraction. Uses UserDefaults for persistence and follows Apple's design patterns.
todos: []
---

# iOS Notes App MVP Implementation

## Architecture Overview

The app follows a three-level navigation hierarchy:

1. **Folders List** → 2. **Notes List (grouped by month)** → 3. **Note Editor**

### Data Models

**`Note.swift`**

- `id: UUID`
- `content: String` (full note text)
- `folderId: UUID` (which folder contains this note)
- `sortDate: Date` (used for month grouping + ordering; does NOT change when edited)
- `createdDate: Date`
- Computed `title: String` - extracts first line from content
- Computed `preview: String` - extracts preview text (2nd line onwards, max 2 lines)

**`Folder.swift`**

- `id: UUID`
- `name: String`
- `isSystemFolder: Bool` (for future system folders)

### ViewModels

**`FoldersViewModel.swift`** (`@Observable`)

- `folders: [Folder]`
- `createFolder(name:)` - creates new folder
- `deleteFolder(_:)` - deletes folder (MVP: skip)
- Persistence via UserDefaults

**`NotesViewModel.swift`** (`@Observable`)

- `notes: [Note]` (filtered by current folder)
- `currentFolderId: UUID?`
- `searchText: String`
- `filteredNotes: [Note]` - filtered by search, sorted by sortDate desc
- `groupedNotes: [String: [Note]]` - grouped by month name
- `createNote()` - creates note in current folder
- `updateNote(_:)` - updates note content (does NOT change sortDate)
- `deleteNote(_:)` - deletes note
- `loadNotes(for folderId:)` - loads notes for a folder
- Persistence via UserDefaults

**`NoteEditorViewModel.swift`** (`@Observable`)

- `note: Note`
- `content: String` (bound to TextEditor)
- `title: String` (computed from first line)
- `save()` - saves note via NotesViewModel

### Views

**`FoldersListView.swift`**

- NavigationStack root
- Large title: "Folders"
- List of folders in a single section labeled "On My iPhone":
- Yellow folder icon + folder name + note count + chevron
- Top-right: Folder-with-plus icon (📁➕) → shows `FolderCreationView` as sheet
- **This is the ONLY place where folders can be created**
- Tap folder → navigates to `NotesListView`
- Bottom-pinned Apple-style search pill filters folder names only
- Bottom-right compose (square-with-pencil) creates a new note in the default "Notes" folder and opens the editor
- Empty state if no folders (keep 📁➕ available; hide/disable compose)
- No "Edit" button for MVP

**`FolderCreationView.swift`**

- TextField for folder name
- "Cancel" and "Create" buttons
- Creates folder and navigates back

**`NotesListView.swift`**

- Shows notes grouped by month headers ("December", "November", etc.)
- Each note row:
- Line 1: **Title** (bold, .primary)
- Line 2: **Date** (dd/MM/yy) + **Preview** (secondary, truncated)
- Swipe to delete
- Top-right "..." menu with: Delete, Copy, Create Folder
- Bottom-pinned Apple-style search pill filters notes within the current folder
- Bottom-right compose (square-with-pencil) creates a new note in the current folder and opens the editor
- **NO folder creation button here** - users must navigate back to FoldersListView
- Empty state: centered icon + "No Notes" text
- Back button shows folder name

**`NoteEditorView.swift`**

- TextEditor for content (no separate title field)
- Title extracted from first line (live updates)
- Toolbar:
- Top-left: back button (shows folder name)
- Top-right: "..." menu with Delete and Share placeholder
- Auto-saves only when navigating away (no explicit save button)

**`EmptyStateView.swift`** (reusable component)

- Centered note icon
- "No Notes" text
- Used in both folders and notes lists

### Key Behaviors

1. **Title Extraction**: First line of content becomes title, updates live as user types
2. **Month Grouping**: Groups by `sortDate`, which does not change when note is edited
3. **Auto-save**: Saves only when navigating away from editor (no explicit save button)
4. **Persistence**: UserDefaults with JSON encoding
5. **Visual Fidelity**: System colors (.primary, .secondary), system typography (.body, .subheadline, .caption), system yellow accent
6. **Language**: English UI strings (match screenshots)

### File Structure

```javascript
notes-workout-log/
├── Models/
│   ├── Note.swift
│   └── Folder.swift
├── ViewModels/
│   ├── FoldersViewModel.swift
│   ├── NotesViewModel.swift
│   └── NoteEditorViewModel.swift
├── Views/
│   ├── FoldersListView.swift
│   ├── FolderCreationView.swift
│   ├── NotesListView.swift
│   ├── NoteEditorView.swift
│   └── EmptyStateView.swift
├── ContentView.swift (updated to show FoldersListView)
└── notes_workout_logApp.swift (no changes)
```



### Implementation Details

**Month Grouping Logic:**

- Use `DateFormatter` with "MMMM" format for month names
- Group notes by month of `sortDate`
- Sort months descending (most recent first)
- Sort notes within month by `sortDate` descending

**Bottom Search UI (Apple-like):**

- Implement a custom bottom-pinned search pill (instead of `.searchable`)
- Folders root: filters folder list only
- Notes list: filters notes in the current folder

**Persistence Keys:**

- `"savedFolders"` - array of Folder
- `"savedNotes"` - array of Note

**Navigation Flow:**

```javascript
FoldersListView (root)
  → FolderCreationView (sheet/modal) [ONLY accessible from FoldersListView]
  → NotesListView (push)
    → NoteEditorView (push)
```

**Important:** Folder creation button (📁➕) is ONLY visible in FoldersListView (top-right). Users must navigate back to root to create folders.**Empty States:**

- Folders list: "No Folders" (if no custom folders)
- Notes list: "No Notes" (if folder is empty)

### MVP Scope

**Included:**

- Create/edit/delete notes
- Create folders
- Month-grouped notes list (by month name only, e.g. "December")
- Bottom-pinned Apple-style search pill
- Folders root: filters folders only
- Notes list: filters notes in current folder
- Auto-title from first line
- Swipe to delete notes (permanent delete in MVP)
- "..." menu:
- Notes list: Delete, Copy, Create Folder
- Editor: Delete, Share placeholder
- Empty states
- System design patterns (yellow accent, system typography)
- Default editable "Notes" folder created on first launch

**Excluded (for MVP):**

- Recently Deleted folder
- All Notes smart folder
- Folder deletion
- "Edit" button (multi-select/reorder mode)
- Rich text formatting
- Checklists
- Attachments