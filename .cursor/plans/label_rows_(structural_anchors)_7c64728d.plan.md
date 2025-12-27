---
name: Label Rows (Structural Anchors)
overview: Replace TextEditor with a custom UITextView wrapper that renders labels (A1., A2., B1., etc.) as atomic, non-editable structural tokens with accent color styling. Implement smart return behavior to auto-insert next label, and atomic deletion (backspace anywhere in label deletes entire label).
todos:
  - id: create-attributed-text-editor
    content: Create AttributedTextEditor UIViewRepresentable wrapper with UITextView, NSAttributedString support, and UITextViewDelegate coordinator
    status: pending
  - id: implement-label-parsing
    content: Implement label parsing regex and attribute application (accent color 60-70% opacity, medium weight) for labels matching pattern
    status: pending
    dependencies:
      - create-attributed-text-editor
  - id: implement-smart-return
    content: "Implement smart return key logic: detect end-of-line label, auto-insert next label (A1→A2), exit mode on second Return"
    status: pending
    dependencies:
      - create-attributed-text-editor
      - implement-label-parsing
  - id: implement-atomic-deletion
    content: "Implement atomic label deletion: detect backspace within label token, delete entire label unit"
    status: pending
    dependencies:
      - create-attributed-text-editor
      - implement-label-parsing
  - id: implement-section-detection
    content: "Implement section detection: parse backwards from cursor to find Skill Work / Main Work headers, enable labels only in these sections"
    status: pending
    dependencies:
      - create-attributed-text-editor
  - id: integrate-note-editor
    content: Replace TextEditor with AttributedTextEditor in NoteEditorView, ensure plain text storage and debounced save still work
    status: pending
    dependencies:
      - create-attributed-text-editor
      - implement-label-parsing
      - implement-smart-return
      - implement-atomic-deletion
      - implement-section-detection
---

# Label Rows (Structural Anchors)

Transform workout template labels (A1., A2., B1., etc.) from plain text into **structural, atomic tokens** that are visually distinct, non-editable, and support smart return behavior.

## Core Requirements

### Label Behavior

- **Atomic units**: Labels like "A1. " cannot be partially deleted; backspace anywhere within deletes the entire label
- **Non-editable**: Labels are structural anchors, not text fields
- **Visual distinction**: System accent color at 60-70% opacity, medium weight, same font size as body text
- **Smart return**: Pressing Return at end of line with label auto-inserts next label (A1 → A2, A2 → A3, etc.)
- **Exit behavior**: Pressing Return again without typing exits label mode (no new label)

### Scope

- **Sections**: Labels only work in **Skill Work** and **Main Work** sections
- **Pattern**: Single letter + number (A1, A2, B1, B2, C1, C2, C3)
- **Format**: "A1. " (letter + number + period + space)
- **Detection**: Parse backwards from cursor to find nearest section header

### Storage

- **Plain text storage**: Keep `Note.content` as plain text string
- **Render-time styling**: Parse labels and apply attributes only when rendering
- **Manual labels**: Detect and style manually typed labels that match pattern

## Implementation

### 1. Create AttributedTextEditor Component

**New File**: [`notes-workout-log/Views/AttributedTextEditor.swift`](notes-workout-log/Views/AttributedTextEditor.swift)Create a `UIViewRepresentable` wrapper around `UITextView` that:

- Manages `NSAttributedString` for label styling
- Intercepts keyboard events (Return key, Backspace)
- Parses labels and applies attributes on text changes
- Detects section context (Skill Work / Main Work)

Key components:

- `Coordinator` class implementing `UITextViewDelegate`
- Label parsing regex: `^([A-Z])(\d+)\.\s` (single letter + number + period + space)
- Attribute application: Accent color at 60-70% opacity, medium weight
- Section detection: Parse backwards from cursor to find "Skill Work" or "Main Work" headers

### 2. Smart Return Key Logic

When Return is pressed:

1. Check if cursor is at end of current line
2. Check if line starts with label pattern (A1., A2., etc.)
3. If yes: Extract letter and number, increment number, insert new label
4. If Return pressed again on empty label line: Don't insert new label (exit mode)

### 3. Atomic Label Deletion

Intercept Backspace key:

1. Detect if cursor is within a label token ("A1. ")
2. If yes: Delete entire label (not just one character)
3. Move cursor to position before label

### 4. Section Detection

Parse backwards from cursor position:

- Look for section headers: "Skill Work" or "Main Work"
- Only enable label behavior if cursor is within these sections
- If cursor is in Warm Up, Mobility, Cool Down, or Notes: Disable label features

### 5. Integration with NoteEditorView

**File**: [`notes-workout-log/Views/NoteEditorView.swift`](notes-workout-log/Views/NoteEditorView.swift)

- Replace `TextEditor(text: $content)` with `AttributedTextEditor(text: $content)`
- Ensure debounced save still works with attributed text
- Convert attributed string back to plain text for storage

### 6. Label Parsing & Styling

On text change:

1. Convert plain text to `NSAttributedString`
2. Find all label matches using regex
3. Apply attributes to label ranges:

- Foreground color: System accent color with 60-70% opacity
- Font weight: Medium
- Font size: Same as body text

4. Update `UITextView.attributedText`

## Technical Details

### Label Regex Pattern

```swift
let labelPattern = #"^([A-Z])(\d+)\.\s"#
// Matches: A1. , A2. , B1. , C3.
// Does NOT match: AA1. , Exercise1.
```

### Next Label Calculation

- Extract letter (A, B, C) and number (1, 2, 3)
- Increment number: A1 → A2, A2 → A3
- If no next label exists in sequence, don't auto-insert

### Storage Format

- Store as plain text: `"A1. Back Squat\nA2. RDL\n"`
- Parse and style on render only
- Copy/paste preserves labels as text

## Edge Cases

- **Manual typing**: If user types "A1. " manually, detect and style it
