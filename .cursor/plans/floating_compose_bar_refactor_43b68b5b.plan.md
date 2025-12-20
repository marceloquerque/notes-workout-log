---
name: Floating Compose Bar Refactor
overview: Refactor search and compose functionality into a floating compose bar at the bottom that expands to show search, matching iOS Notes behavior. Replace navigation bar search and bottom toolbar compose buttons in both FoldersListView and NotesListView.
todos:
  - id: create_floating_bar
    content: Create FloatingComposeBar.swift component with expand/collapse animation, search field, and compose button
    status: completed
  - id: update_folders_view
    content: Remove .searchable and bottomBar toolbar from FoldersListView, add FloatingComposeBar overlay
    status: completed
    dependencies:
      - create_floating_bar
  - id: update_notes_view
    content: Remove .searchable and bottomBar toolbar from NotesListView, add FloatingComposeBar overlay
    status: completed
    dependencies:
      - create_floating_bar
---

# Floating Compose Bar Refactor

Refactor the search bar and compose button into a floating compose bar at the bottom of the screen, matching iOS Notes app behavior. The bar shows a compose button initially and expands to reveal a search field when tapped.

## Current State

- **FoldersListView** (`notes-workout-log/Views/FoldersListView.swift`):
- Uses `.searchable()` modifier with `.navigationBarDrawer` placement (line 89)
- Has compose button in `.bottomBar` toolbar placement (lines 74-87)
- **NotesListView** (`notes-workout-log/Views/NotesListView.swift`):
- Uses `.searchable()` modifier with `.navigationBarDrawer` placement (line 117)
- Has compose button in `.bottomBar` toolbar placement (lines 104-115)

## Implementation Plan

### 1. Create FloatingComposeBar Component

**New File**: `notes-workout-log/Views/FloatingComposeBar.swift`Create a reusable component that:

- **Collapsed state**: Circular floating action button (FAB) positioned at bottom-right corner
- Shows compose icon (`square.and.pencil`) in a circular button
- Uses system background with blur effect (`.ultraThinMaterial`)
- Applies shadow/elevation for depth
- Respects safe area insets (bottom padding)
- **Expanded state**: Full-width rounded rectangle bar spanning horizontally with padding
- Search field on the left, compose button on the right (side-by-side)
- Search field uses `TextField` with placeholder "Search"
- Both elements maintain proper spacing and alignment
- Same styling as collapsed (blur background, shadow, rounded corners ~16-20pt)
- **State management**:
- `@State private var isExpanded: Bool = false`
- `@State private var searchText: String = ""`
- `@FocusState private var isSearchFocused: Bool`
- **Behavior**:
- Tapping collapsed button expands the bar and auto-focuses search field (shows keyboard)
- Collapses automatically when `searchText` becomes empty
- Uses spring animation for smooth expand/collapse transitions
- Moves up with keyboard (stays above keyboard when visible)
- **API**:
- Accepts `searchText: Binding<String>` for two-way binding
- Accepts `onCompose: () -> Void` callback for compose action
- Optional `onSearchChange: ((String) -> Void)?` for search text changes

### 2. Update FoldersListView

**File**: `notes-workout-log/Views/FoldersListView.swift`

- Remove `.searchable()` modifier (line 89)
- Remove `.bottomBar` toolbar item with compose button (lines 74-87)
- Add bottom padding/inset to the `List` to prevent content overlap with floating bar
- Add `FloatingComposeBar` as an overlay:
- Bind `searchText` state to the bar's `searchText` binding
- Pass `onCompose` callback that creates note in default folder (existing logic from lines 78-81)
- Handle keyboard-aware positioning (bar moves up with keyboard)
- Keep existing `searchText` state and `filteredFolders` logic unchanged

### 3. Update NotesListView

**File**: `notes-workout-log/Views/NotesListView.swift`

- Remove `.searchable()` modifier (line 117)
- Remove `.bottomBar` toolbar item with compose button (lines 104-115)
- Add bottom padding/inset to the `List` to prevent content overlap with floating bar
- Add `FloatingComposeBar` as an overlay:
- Bind `searchText` state to the bar's `searchText` binding
- Pass `onCompose` callback that creates note in current folder (existing logic from lines 108-110)
- Handle keyboard-aware positioning (bar moves up with keyboard)
- Keep existing `searchText` state and `filteredNotes` logic unchanged

### 4. Styling Details

The floating bar should:

- **Collapsed**: Circular button (~56pt diameter) at bottom-right with ~16-20pt padding from edges
- **Expanded**: Full-width bar with horizontal padding (~16-20pt from screen edges)
- Use `.safeAreaInset(edge: .bottom)` or overlay with safe area padding for proper positioning
- Rounded corners: circular when collapsed, ~16-20pt radius when expanded
- Apply shadow/elevation (`.shadow()` modifier) for depth
- Use system background with blur effect (`.background(.ultraThinMaterial)`)
- Match iOS Notes visual style (system gray background, appropriate icon colors)
- Animate smoothly with spring animation (`.animation(.spring(), value: isExpanded)`)
- Icons: Use SF Symbols with appropriate sizing and weights

## Technical Considerations

- **Keyboard handling**: 
- Use `@FocusState` to manage search field focus
- Observe keyboard height using `KeyboardResponder` or similar mechanism
- Adjust bar position to stay above keyboard when visible
- Dismiss keyboard when bar collapses (set `isSearchFocused = false`)
- **List padding**: 
- Add `.safeAreaInset(edge: .bottom)` to List views with appropriate height
- Or use `.padding(.bottom, barHeight + safeAreaBottom)` to prevent content overlap
- Calculate padding based on collapsed bar height (~56pt + safe area)
- **Animation**: 
- Use `.animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)` for smooth transitions
- Animate width, position, and opacity changes
- **State synchronization**: 
- Two-way binding for `searchText` ensures parent views stay in sync
- Collapse when `searchText.isEmpty` (observe changes)
- **Accessibility**: 
- Add appropriate accessibility labels and hints