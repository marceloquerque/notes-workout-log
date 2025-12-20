---
name: Rename to Logbook and Add TabView
overview: Rename "On My iPhone" to "Logbook" and wrap the app in a TabView with horizontal swipe paging between Logbook (current FoldersListView) and Calendar (placeholder view).
todos:
  - id: update-string-constant
    content: Update AppConstants.swift to change 'onMyiPhone' from 'On My iPhone' to 'Logbook'
    status: completed
  - id: create-calendar-view
    content: Create CalendarView.swift as a placeholder view for the Calendar tab
    status: completed
  - id: modify-content-view
    content: Wrap FoldersListView in TabView with horizontal swipe paging in ContentView.swift
    status: completed
    dependencies:
      - update-string-constant
      - create-calendar-view
---

# Rename "On My iPhone" to "Logbook" and Add TabView with Horizontal Swipe Paging

## Overview

1. Update the string constant from "On My iPhone" to "Logbook" in `AppConstants.swift`
2. Modify `ContentView.swift` to wrap the current view hierarchy in a `TabView` with horizontal swipe paging
3. Create a placeholder `CalendarView` for the Calendar tab

## Implementation Details

### 1. Update String Constant

- **File**: `notes-workout-log/Support/AppConstants.swift`
- Change `onMyiPhone` from `"On My iPhone"` to `"Logbook"` (line 50)
- This will automatically update the section header in `FoldersListView`

### 2. Modify ContentView Structure

- **File**: `notes-workout-log/ContentView.swift`
- Wrap the existing `FoldersListView` in a `TabView` with two tabs:
- **Tab 1**: Logbook (current `FoldersListView` wrapped in a container)
- **Tab 2**: Calendar (placeholder view)
- Apply `.tabViewStyle(.page)` for horizontal swipe paging
- Use `.indexViewStyle(.page(backgroundDisplayMode: .always))` to make tab indicators faint/visible
- Ensure the alert from `NotesStore` still works (it should propagate through the TabView)

### 3. Create Calendar Placeholder View

- **File**: `notes-workout-log/Views/CalendarView.swift` (new file)
- Create a simple placeholder view with a title "Calendar" and a message indicating it will be implemented later
- Use similar styling to maintain visual consistency

## Architecture Flow

```javascript
ContentView
├── TabView (horizontal swipe paging)
│   ├── Tab 1: Logbook
│   │   └── FoldersListView (existing)
│   │       └── Alert (from NotesStore)
│   └── Tab 2: Calendar
│       └── CalendarView (placeholder)
```



## Notes