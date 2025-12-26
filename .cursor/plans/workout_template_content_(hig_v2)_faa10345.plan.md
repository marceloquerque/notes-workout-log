---
name: Workout Template Content (HIG v2)
overview: Update Upper/Lower templates to a clean, HIG-aligned plain-text skeleton (Title Case headings, 3-blank-line spacing, “sets • rest” summary lines, Notes at bottom); keep Full Body minimal for now.
todos:
  - id: update-upper-lower-template-content
    content: Update `upper` and `lower` `WorkoutTemplate(content:)` strings in `notes-workout-log/Support/TemplateStore.swift` to the HIG v2 template body; keep `full_body` unchanged.
    status: completed
---

# Workout Template Content (HIG v2)

Replace the **Upper** and **Lower** template bodies with a clean, Apple HIG–aligned plain-text skeleton that reads like subheadings + body text inside a `TextEditor`.

## Locked decisions

- **Upper + Lower**: same template body.
- **Full Body**: keep unchanged (current minimal content), implement later.
- **Headings**: Title Case, no punctuation (e.g. “Warm Up”).
- **Set/rest line**: use **“sets • rest …”** (e.g. “3 sets • rest 90s”).
- **Spacing**: **3 blank lines** between major sections.
- **Notes placement**: **Notes** goes **after Cool Down**.
- **Text-only for now**: labels like A1/B2 are plain text (no locking/tinting yet with `TextEditor`).

## Change

Update [`notes-workout-log/Support/TemplateStore.swift`](notes-workout-log/Support/TemplateStore.swift):

- Replace `content` for `id: "upper"` and `id: "lower"` with the exact template body below.
- Leave `id: "full_body"` as-is.

Target template body:

```text
Warm Up



Mobility



Skill Work
3 sets • rest TBD
A1. 
A2. 



Main Work
3 sets • rest 90s
A1. 
A2. 

3 sets • rest 60s
B1. 
B2. 

2-3 sets • rest 30-60s
C1. 
C2. 
C3. 



Cool Down



Notes

```



## Rationale (HIG)