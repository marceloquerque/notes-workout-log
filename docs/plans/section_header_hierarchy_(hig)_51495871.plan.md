---
name: Section Header Hierarchy (HIG)
overview: Make workout templates readable by increasing section header prominence (Title3 semibold) and demoting prescription lines (Subheadline + secondary), without changing storage or editing behavior.
todos:
  - id: enumerate-line-ranges
    content: Add line enumeration helper using NSString.enumerateSubstrings to get accurate per-line NSRange values.
    status: pending
  - id: style-section-headers
    content: Detect section header lines (trim + lowercase vs WorkoutSection rawValue) and apply Title3 semibold attributes.
    status: pending
    dependencies:
      - enumerate-line-ranges
  - id: style-prescription-lines
    content: Detect prescription lines via regex and apply Subheadline + secondaryLabel styling, preserving existing label-token styling order.
    status: pending
    dependencies:
      - enumerate-line-ranges
---

# Section Header Hierarchy (HIG)

## Decisions locked

- **Section header typography**: `.title3` size + **semibold** weight.
- **Prescription line typography** (e.g., `3 sets • rest 90s`, `2-3 sets • rest 30-60s`): `.subheadline` size + `secondaryLabel`.
- **Prescription line regex**: Strict—only match lines with `•` bullet character (not `-` or `:` variations).
- **Label vs prescription conflict**: Label token styling wins; if a line has both (e.g., `A1. 3 sets • rest 90s`), label tokens keep their accent styling and the prescription styling is skipped for that line.
- **Newline handling**: Exclude trailing newline from styled ranges (headers and prescriptions).

## Goal

Reduce visual competition between headers and content in the `UITextView`-backed editor, while preserving plain-text storage and existing label-token styling.

## Implementation (single-file change)

### 1) Add robust line-range enumeration

**File**: [`notes-workout-log/Views/AttributedTextEditor.swift`](notes-workout-log/Views/AttributedTextEditor.swift)Avoid manual `currentLocation += line.count + 1` accounting. Enumerate lines using `NSString.enumerateSubstrings(in:options:)` to get **exact `NSRange` per line**.Output of enumeration should provide:

- `lineString` (without newline)
- `lineRange` (range in the full string, **excluding trailing newline**)

### 2) Detect lines to style

Reuse existing `WorkoutSection` raw values and trimming rules.

- **Section header line**: trimmed + lowercased line equals one of `WorkoutSection.allCases.map(\.rawValue)`.
- **Prescription line**: line matches a strict regex (bullet character `•` required):
- `^\s*\d+(?:-\d+)?\s+sets\s*•\s*rest\s+.+$` (case-sensitive, since "sets" is always lowercase in templates)
- Covers: `3 sets • rest TBD`, `3 sets • rest 90s`, `2-3 sets • rest 30-60s`.
- **Does NOT match**: `3 sets - rest 90s`, `3 sets: rest 90s`, or other separator variations.

### 3) Apply attributes in `applyTextWithStyling`

Keep the existing pipeline but add two new styling passes.**Order of application (important):**

1. Base body styling (all text)
2. Prescription line styling (subheadline + secondary) — **skip lines that contain label tokens**
3. Section header styling (title3 + semibold)
4. Existing label-token styling (accent @ 0.65 + medium) in Skill Work/Main Work — **overrides prescription styling if conflict**

**Conflict resolution**: If a line has both a label token (e.g., `A1. `) and matches the prescription regex, label token styling wins and prescription styling is not applied to that line.**Dynamic Type correctness**:

- Use `UIFont.preferredFont(forTextStyle:)` + `UIFontMetrics(forTextStyle:)` so semibold fonts scale properly.

## Visual result

- **Headers**: clearly “section titles” (Title3 semibold)
- **Prescription lines**: visually subordinate metadata (Subheadline secondary)
- **Label tokens**: remain structural anchors with accent styling
