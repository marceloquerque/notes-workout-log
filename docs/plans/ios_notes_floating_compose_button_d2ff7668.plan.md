---
name: iOS Notes Floating Compose Button
overview: Replace the bottom toolbar compose buttons with a simple floating action button (FAB) matching iOS Notes design. The button is a circular FAB at bottom-right that immediately creates a note when tapped. Search functionality remains separate in NotesListView using .searchable().
todos:
  - id: create_floating_button
    content: Create FloatingComposeButton.swift component - simple circular FAB matching iOS Notes design
    status: completed
  - id: update_folders_view
    content: Remove .bottomBar toolbar from FoldersListView, add FloatingComposeButton overlay positioned bottom-right (no list padding)
    status: completed
    dependencies:
      - create_floating_button
  - id: update_notes_view
    content: Remove .bottomBar toolbar from NotesListView, add FloatingComposeButton overlay positioned bottom-right (no list padding), keep .searchable() unchanged
    status: completed
    dependencies:
      - create_floating_button
---

# iOS Notes Floating Compose Button

Replace the `.bottomBar` toolbar compose buttons with a simple floating action button (FAB) that matches iOS Notes design exactly. The compose button is a primary action, not a navigation control.**Key improvements:**

- Removes the heavy white toolbar background created by `.bottomBar` placement
- Replaces with a lighter, clearer floating button using `.ultraThinMaterial` blur effect

## Current State

- **FoldersListView** ([`notes-workout-log/Views/FoldersListView.swift`](notes-workout-log/Views/FoldersListView.swift)):
- Compose button in `.bottomBar` toolbar placement (lines 64-77)
- No search functionality
- **NotesListView** ([`notes-workout-log/Views/NotesListView.swift`](notes-workout-log/Views/NotesListView.swift)):
- Compose button in `.bottomBar` toolbar placement (lines 104-115)
- Search functionality using `.searchable()` modifier (line 117) - **keep as-is**

## Implementation Plan

### 1. Create FloatingComposeButton Component

**New File**: [`notes-workout-log/Views/FloatingComposeButton.swift`](notes-workout-log/Views/FloatingComposeButton.swift)Create a simple floating action button component that matches iOS Notes:

- **Design**:
- Circular button (~56pt diameter)
- Positioned at bottom-right corner
- ~20pt padding from screen edges (respects safe area)
- Uses `.ultraThinMaterial` blur effect for a lighter, clearer appearance (matches iOS Notes)
- Applies shadow for depth (`.shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)`)
- Icon: `square.and.pencil` SF Symbol, appropriate size (~24pt)
- Icon color: `.primary` or system accent
- **Behavior**:
- Single tap immediately triggers `onCompose` callback
- No expansion, no search integration
- Respects safe area insets (bottom padding)
- Stays above keyboard when keyboard appears (automatically via safe area insets)
- **API**:
- `onCompose: () -> Void` - callback when button is tapped
- Optional `isEnabled: Bool = true` - disable state (e.g., when no folders exist)
- **Styling Details** (matching iOS Notes):
- Background: `.background(.ultraThinMaterial)` - lighter, clearer blur effect
- Shadow: `.shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)`
- Size: Fixed 56pt diameter (standard FAB size)
- Position: Bottom-right corner (matches screenshot positioning exactly)
- Padding: ~20pt from right edge, ~20pt from bottom edge (plus safe area inset)
- Safe area: Respects bottom safe area inset automatically via `.safeAreaPadding()`

### 2. Update FoldersListView

**File**: [`notes-workout-log/Views/FoldersListView.swift`](notes-workout-log/Views/FoldersListView.swift)

- Remove `.bottomBar` toolbar item (lines 64-77) - **this removes the white toolbar background**
- Add `FloatingComposeButton` as an overlay using `.overlay(alignment: .bottomTrailing)`:
- Pass `onCompose` callback that creates note in default folder (existing logic from lines 68-71)
- Pass `isEnabled: !folders.isEmpty` to disable when no folders exist
- **No list padding needed** - button floats above content, allowing list items to scroll underneath

### 3. Update NotesListView

**File**: [`notes-workout-log/Views/NotesListView.swift`](notes-workout-log/Views/NotesListView.swift)

- Remove `.bottomBar` toolbar item (lines 104-115) - **this removes the white toolbar background**
- **Keep** `.searchable()` modifier (line 117) - search remains separate
- Add `FloatingComposeButton` as an overlay using `.overlay(alignment: .bottomTrailing)`:
- Pass `onCompose` callback that creates note in current folder (existing logic from lines 108-110)
- Button is always enabled (folder context exists)
- **No list padding needed** - button floats above content, allowing list items to scroll underneath

### 4. Technical Considerations

- **Positioning**: Use `.overlay(alignment: .bottomTrailing)` on the main view container (List or Group)
- Button component should use `.padding(.trailing, 20).padding(.bottom, 20).safeAreaPadding(.bottom)` for proper spacing
- Position matches screenshot: bottom-right corner exactly
- **Keyboard handling**: Button automatically moves up with keyboard via safe area insets (no manual keyboard observer needed)
- **Content overlap**: List content is allowed to scroll underneath the button (true floating behavior, no reserved space)
- **Animation**: Use spring animation for any state changes (e.g., enable/disable)
- **Accessibility**: Add `.accessibilityLabel("New Note")` and `.accessibilityHint("Creates a new note")`
- **Visual hierarchy**: The FAB should appear above list content but below modals/sheets

## Design Specifications (iOS Notes Match)

- **Button size**: 56pt × 56pt (standard FAB)
- **Corner radius**: 28pt (fully circular)