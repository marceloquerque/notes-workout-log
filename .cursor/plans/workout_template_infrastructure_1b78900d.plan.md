---
name: Workout Template Infrastructure
overview: "Add template insertion infrastructure to NoteEditorView: detect new/unedited notes, add Templates menu item with submenu containing 3 initial templates (Upper, Lower, Full Body), and implement template insertion mechanism."
todos:
  - id: add_template_detection
    content: Add isNewNote computed property to NoteEditorView to detect new/unedited notes
    status: completed
  - id: create_template_model
    content: Create WorkoutTemplate struct in Models/WorkoutTemplate.swift
    status: completed
  - id: create_template_store
    content: Create TemplateStore class in Support/TemplateStore.swift with 3 initial templates (Upper, Lower, Full Body)
    status: completed
    dependencies:
      - create_template_model
  - id: add_string_constants
    content: Add template-related strings to AppConstants.swift
    status: completed
  - id: update_menu
    content: Add Templates menu item with submenu to NoteEditorView toolbar menu, disabled when !isNewNote
    status: completed
    dependencies:
      - add_template_detection
      - add_string_constants
  - id: add_insert_method
    content: Add insertTemplate() method to NoteEditorView for inserting template content
    status: completed
    dependencies:
      - create_template_model
  - id: integrate_template_store
    content: Add TemplateStore to environment in NoteEditorView and notes_workout_logApp.swift
    status: completed
    dependencies:
      - create_template_store
---

# Workout Template In

frastructureAdd template insertion functionality to the note editor, allowing users to insert pre-formatted workout structures into new notes via the menu.

## Overview

When a user opens a new note (empty content and default title), the "..." menu will include a "Templates" option. Clicking it shows a submenu with 3 initial templates: "Upper", "Lower", and "Full Body". Selecting a template inserts its content directly into the TextEditor.

## Implementation Details

### 1. Template Detection Logic

**File**: [`notes-workout-log/Views/NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift)Add a computed property to determine if a note is new/unedited:

```swift
private var isNewNote: Bool {
    content.isEmpty && (titleDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                        titleDraft.trimmingCharacters(in: .whitespacesAndNewlines) == AppStrings.newNoteTitle)
}
```

A note is considered "new" when:

- Content is empty
- Title is empty or equals the default "New Note" title

### 2. Template Model & Storage

**New File**: [`notes-workout-log/Models/WorkoutTemplate.swift`](notes-workout-log/Models/WorkoutTemplate.swift)Create a simple struct to represent templates (conforming to Identifiable for ForEach):

```swift
struct WorkoutTemplate: Identifiable {
    let id: String
    let name: String
    let content: String
}
```

**New File**: [`notes-workout-log/Support/TemplateStore.swift`](notes-workout-log/Support/TemplateStore.swift)Create a store to manage templates with 3 initial templates:

```swift
@Observable
final class TemplateStore {
    var templates: [WorkoutTemplate]
    
    init() {
        self.templates = [
            WorkoutTemplate(
                id: "upper",
                name: "Upper",
                content: "Upper Body\n\n"
            ),
            WorkoutTemplate(
                id: "lower",
                name: "Lower",
                content: "Lower Body\n\n"
            ),
            WorkoutTemplate(
                id: "full_body",
                name: "Full Body",
                content: "Full Body\n\n"
            )
        ]
    }
    
    // Future: methods to load templates from storage/user defaults
}
```

Note: Template content is minimal for now—just the workout type name. Future iterations can add structured exercise lists.

### 3. Menu Integration

**File**: [`notes-workout-log/Views/NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift)Modify the existing menu (lines 71-87) to:

- Add "Templates" menu item above "Delete"
- Show submenu when templates are available
- Disable "Templates" when `!isNewNote`
- Show empty state message if no templates exist

Structure:

```swift
Menu {
    Menu("Templates") {
        ForEach(templateStore.templates) { template in
            Button {
                insertTemplate(template)
            } label: {
                Text(template.name)
            }
        }
    }
    .disabled(!isNewNote)
    
    Divider()
    
    Button(role: .destructive) { ... } // Delete
    Button { ... } // Share
}
```



### 4. Template Insertion

**File**: [`notes-workout-log/Views/NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift)Add method to insert template content:

```swift
private func insertTemplate(_ template: WorkoutTemplate) {
    content = template.content
    // Trigger save after insertion
    scheduleDebouncedSave(template.content)
}
```

When a template is selected, replace the entire `content` string (since it's a new note, there's nothing to preserve).

### 5. String Constants

**File**: [`notes-workout-log/Support/AppConstants.swift`](notes-workout-log/Support/AppConstants.swift)Add template-related strings:

```swift
// MARK: Templates
static let templates = "Templates"
static let noTemplatesAvailable = "No templates available"
```



### 6. Environment Integration

**File**: [`notes-workout-log/Views/NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift)Add `TemplateStore` as an environment dependency (for future use):

```swift
@Environment(TemplateStore.self) private var templateStore
```

**File**: [`notes-workout-log/notes_workout_logApp.swift`](notes-workout-log/notes_workout_logApp.swift)Create and inject `TemplateStore` instance into the environment.

## Data Flow

```javascript
User clicks "..." menu
    ↓
Menu shows "Templates" (enabled only if isNewNote)
    ↓
User clicks "Templates"
    ↓
Submenu shows 3 options: "Upper", "Lower", "Full Body"
    ↓
User selects template
    ↓
insertTemplate() replaces content
    ↓
Auto-save triggers via existing debounced save mechanism
```



## Future Extensibility

- Expand template content with structured exercise lists (sets, reps, weight)
- Load templates from UserDefaults or a plist file
- Allow users to create custom templates
- Support template variables/placeholders
- Add more template types (Push/Pull/Legs, Cardio, etc.)

## Notes

- Templates only work on new notes to preserve the "free-form" editing experience