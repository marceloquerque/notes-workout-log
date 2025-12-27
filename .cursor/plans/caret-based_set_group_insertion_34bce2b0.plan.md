---
name: Caret-based Set Group Insertion
overview: Add a context menu triggered by long-pressing the text cursor (caret) that allows inserting a set group block at the cursor position, following Apple HIG patterns for text editing context menus.
todos:
  - id: add_string_constant
    content: Add 'Insert Set Group' string constant to AppConstants.swift
    status: completed
  - id: add_label_letter_detection
    content: Add section-scoped nextLabelLetter helper to Coordinator (A/B/C resets per section)
    status: completed
  - id: add_set_group_insertion
    content: Add insertSetGroup method to Coordinator that builds and inserts set group block at cursor position
    status: completed
  - id: implement_context_menu
    content: Implement iOS edit-menu customization hook to add Insert Set Group to the system caret menu
    status: completed
---

# Caret-based Set Group Insertion

Add a context menu that appears when users long-press the text cursor (caret), providing an "Insert Set Group" option that inserts a formatted set group block at the cursor position.

## Overview

When users long-press the caret in the text editor, a context menu appears (mirroring iOS paste/formatting menus). Selecting "Insert Set Group" inserts a formatted block:

```
3 sets • rest 90s
A1.
A2.
```

The implementation follows Apple HIG patterns for text editing context menus and integrates with existing label token logic.

## Implementation Details

### 1. Context Menu Integration

**File**: [`notes-workout-log/Views/AttributedTextEditor.swift`](notes-workout-log/Views/AttributedTextEditor.swift)

Add the modern UIKit edit-menu customization hook on the `UITextViewDelegate` (iOS 16+): `textView(_:editMenuForTextIn:suggestedActions:)` (returns a `UIMenu?`) to the `Coordinator` class.

- Only offer the command when it’s contextually correct:
  - Selection is an insertion point (caret): `textView.selectedRange.length == 0` (recommended; avoids destructive replacement)
  - Caret is inside a label-enabled section: `SectionDetector.labelsEnabled(at: selection.location, in: textView.text)`
- Create a `UIAction` titled `AppStrings.insertSetGroup`, and merge it into the returned `UIMenu` alongside `suggestedActions` (system items like Paste/Select/Format).
- Return `nil` when not offering the command so the system menu remains unchanged.

This keeps behavior consistent with Apple Notes: it’s the same system edit menu, just with one context-specific command added.

### 2. Set Group Insertion Logic

**File**: [`notes-workout-log/Views/AttributedTextEditor.swift`](notes-workout-log/Views/AttributedTextEditor.swift)

Add method `insertSetGroup(at:in:)` to `Coordinator`:

- Get current cursor position from `textView.selectedRange`
- Determine next label letter (A, B, C, etc.) **within the current section** (Skill Work or Main Work only; each section has its own sequence):
  - Default to `"A"` when no prior groups exist in that section
  - Otherwise pick the max letter used in that section and increment (A → B → C …)
- Build set group block string:

  ```
  3 sets • rest 90s
  {letter}1.
  {letter}2.
  ```

- Insert at cursor position using `textView.insertText(_:)`
- Update binding and refresh styling

Insertion formatting rules (HIG/predictability):

- If caret is mid-line (not at a line boundary), insert a leading newline before the block.
- After insertion, move the caret to the first “field”: immediately after `{letter}1. ` (recommended), not the end of the block.
  - Track `insertionStart = originalSelection.location`.
  - Compute `caretOffset` as the UTF-16 length of: optional leading newline + `"3 sets • rest 90s\n"` + `"{letter}1. "`.
  - Insert the full block, then set `textView.selectedRange = NSRange(location: insertionStart + caretOffset, length: 0)`.

### 3. Label Letter Detection

**File**: [`notes-workout-log/Views/AttributedTextEditor.swift`](notes-workout-log/Views/AttributedTextEditor.swift)

Add helper method `nextLabelLetter(in:text:)` to `Coordinator` (section-scoped):

- Compute the **current section** at the caret using `SectionDetector.currentSection(at:in:)`.
- Compute the **section body range**:
  - Find the nearest section header line above the caret (`SectionDetector.isSectionHeader`), using `LineUtilities.enumerateLines(in:)` and line `NSRange`s.
  - Find the next section header line below the caret (or end of text).
  - The section body range is between those header boundaries (excluding the header line itself).
- Parse all label tokens with `LabelTokenParser.findTokens(in:)`, then filter to tokens whose `range.location` falls inside the section body range.
- Return `"A"` if none found, else `(maxLetter + 1)`.

### 4. String Constants

**File**: [`notes-workout-log/Support/AppConstants.swift`](notes-workout-log/Support/AppConstants.swift)

Add string constant:

```swift
// MARK: Set Groups
static let insertSetGroup = "Insert Set Group"
```

### 5. Context Menu Action Handler

**File**: [`notes-workout-log/Views/AttributedTextEditor.swift`](notes-workout-log/Views/AttributedTextEditor.swift)

In `textView(_:editMenuForTextIn:suggestedActions:)`:

- Create `UIAction` with title from `AppStrings.insertSetGroup`
- Use system image `"list.bullet"` or similar
- Handler calls `insertSetGroup(...)` on the coordinator, operating on the current `textView`
- Return a `UIMenu` that includes `suggestedActions` plus the new action (place near the front to keep it discoverable)

## Data Flow

```mermaid
flowchart TD
    A[User long-presses caret] --> B[iOS shows context menu]
    B --> C[textView:editMenuForTextIn:suggestedActions called]
    C --> D{Caret in SkillWork_or_MainWork and selection_isEmpty}
    D -->|Yes| E[Return UIMenu including InsertSetGroup]
    D -->|No| F[Return nil (system menu unchanged)]
    E --> F
    F --> G[User selects Insert Set Group]
    G --> H[insertSetGroup called]
    H --> I[Determine next label letter within current section]
    I --> J[Build set group block]
    J --> K[Insert at cursor position]
    K --> L[Update text binding]
    L --> M[Refresh styling]
```

## Technical Considerations

### Cursor Position Handling

- Use `textView.selectedRange.location` for insertion point
- Ensure cursor is at valid position (not inside label token)
- Handle edge cases (empty text, end of text, etc.)

### Label Letter Logic

- Compute letters **per section** (Skill Work and Main Work each have their own A/B/C sequence).
- Use highest letter found in that section + 1 for next group.
- If letter would exceed Z, fall back to A (explicitly define behavior) or block insertion with a safe, user-visible decision (future).

### Integration with Existing Features

- Respect `SectionDetector.labelsEnabled` - only show menu in skill work/main work sections
- Use existing `LabelTokenParser` for label detection
- Follow existing styling refresh pattern after insertion
- Maintain `isUpdatingText` flag to prevent delegate loops

## Testing Considerations

- Test insertion at various cursor positions (start, middle, end of text)
- Test in different sections (warm up, skill work, main work, notes)
- Verify label letter progression (A → B → C)
- Test with existing label tokens present
- Verify styling refresh after insertion
- Test menu appearance/disappearance timing
