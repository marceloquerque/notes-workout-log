---
name: Remove search bar from Logbook view
overview: Remove the .searchable() modifier from FoldersListView (Logbook view) while keeping it on NotesListView. The search state and filtering logic in FoldersListView will remain but be unused.
todos:
  - id: remove_searchable_folders
    content: Remove .searchable() modifier from FoldersListView (line 89)
    status: completed
---

# Remove Search Bar from Logbook View

Remove the search bar UI from the Logbook view (`FoldersListView`) while keeping search functionality intact on the Notes list view (`NotesListView`).

## Current State

- **FoldersListView** (`notes-workout-log/Views/FoldersListView.swift`):
- Has `.searchable()` modifier on line 89
- Has `searchText` state (line 16) and `filteredFolders` logic (lines 22-27) - these will remain unused
- **NotesListView** (`notes-workout-log/Views/NotesListView.swift`):
- Has `.searchable()` modifier on line 117
- Has `searchText` state (line 16) and `filteredNotes` logic (lines 30-39)
- All search functionality remains unchanged

## Implementation

### Remove Search Bar from FoldersListView

**File**: `notes-workout-log/Views/FoldersListView.swift`

- Remove the `.searchable()` modifier (line 89)
- Keep `searchText` state and `filteredFolders` logic unchanged (as requested, even though unused)

The view will continue using `filteredFolders` which will always return all folders since `searchText` will remain empty without the UI to modify it.