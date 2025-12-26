//
//  AttributedTextEditor.swift
//  notes-workout-log
//

import SwiftUI
import UIKit

// MARK: - Label Token Helpers

/// Represents a parsed label token (e.g., "A1. ")
struct LabelToken: Equatable {
    let letter: Character
    let number: Int
    let range: NSRange
    
    var text: String { "\(letter)\(number). " }
    
    func next() -> LabelToken {
        LabelToken(letter: letter, number: number + 1, range: NSRange(location: 0, length: 0))
    }
}

enum LabelTokenParser {
    /// Regex: line-start, uppercase letter, positive integer, period, space
    private static let pattern = #"(?m)^([A-Z])([1-9]\d*)\.\s"#
    private static let regex = try! NSRegularExpression(pattern: pattern, options: [])
    
    /// Find all label tokens in the given text
    static func findTokens(in text: String) -> [LabelToken] {
        let nsString = text as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let matches = regex.matches(in: text, options: [], range: range)
        
        return matches.compactMap { match -> LabelToken? in
            guard match.numberOfRanges == 3,
                  let letterRange = Range(match.range(at: 1), in: text),
                  let numberRange = Range(match.range(at: 2), in: text),
                  let letter = text[letterRange].first,
                  let number = Int(text[numberRange]) else {
                return nil
            }
            return LabelToken(letter: letter, number: number, range: match.range)
        }
    }
    
    /// Find token containing or immediately before the given location
    static func token(at location: Int, in tokens: [LabelToken]) -> LabelToken? {
        tokens.first { NSLocationInRange(location, $0.range) }
    }
    
    /// Find token that the range intersects with
    static func token(intersecting range: NSRange, in tokens: [LabelToken]) -> LabelToken? {
        tokens.first { NSIntersectionRange($0.range, range).length > 0 }
    }
}

// MARK: - Section Detection

enum WorkoutSection: String, CaseIterable {
    case warmUp = "warm up"
    case mobility = "mobility"
    case skillWork = "skill work"
    case mainWork = "main work"
    case coolDown = "cool down"
    case notes = "notes"
    
    var supportsLabels: Bool {
        self == .skillWork || self == .mainWork
    }
}

enum SectionDetector {
    private static let headers: [String: WorkoutSection] = [
        "warm up": .warmUp,
        "mobility": .mobility,
        "skill work": .skillWork,
        "main work": .mainWork,
        "cool down": .coolDown,
        "notes": .notes
    ]
    
    /// Regex for prescription lines: "3 sets • rest TBD", "2-3 sets • rest 90s"
    private static let prescriptionPattern = #"^\s*\d+(?:-\d+)?\s+sets\s*•\s*rest\s+.+$"#
    private static let prescriptionRegex = try! NSRegularExpression(pattern: prescriptionPattern, options: [])
    
    /// Detect which section the cursor is in by scanning backward for headers
    static func currentSection(at cursorPosition: Int, in text: String) -> WorkoutSection? {
        let nsString = text as NSString
        guard cursorPosition <= nsString.length else { return nil }
        
        // Get text up to cursor
        let textBeforeCursor = nsString.substring(to: cursorPosition)
        let lines = textBeforeCursor.components(separatedBy: .newlines)
        
        // Scan backward through lines to find the last header
        for line in lines.reversed() {
            let trimmed = line.trimmingCharacters(in: .whitespaces).lowercased()
            if let section = headers[trimmed] {
                return section
            }
        }
        return nil
    }
    
    /// Check if labels should be active at the given cursor position
    static func labelsEnabled(at cursorPosition: Int, in text: String) -> Bool {
        currentSection(at: cursorPosition, in: text)?.supportsLabels ?? false
    }
    
    /// Check if a line is a section header
    static func isSectionHeader(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces).lowercased()
        return headers[trimmed] != nil
    }
    
    /// Check if a line is a prescription line (e.g., "3 sets • rest 90s")
    static func isPrescriptionLine(_ line: String) -> Bool {
        let range = NSRange(location: 0, length: (line as NSString).length)
        return prescriptionRegex.firstMatch(in: line, options: [], range: range) != nil
    }
}

// MARK: - Line Utilities

/// Represents a single line with its content and range (excluding trailing newline)
struct LineInfo {
    let content: String
    let range: NSRange
}

enum LineUtilities {
    /// Enumerate all lines in text, providing content and range (excluding trailing newline)
    static func enumerateLines(in text: String) -> [LineInfo] {
        var lines: [LineInfo] = []
        let nsString = text as NSString
        
        nsString.enumerateSubstrings(
            in: NSRange(location: 0, length: nsString.length),
            options: [.byLines, .substringNotRequired]
        ) { _, substringRange, _, _ in
            let content = nsString.substring(with: substringRange)
            lines.append(LineInfo(content: content, range: substringRange))
        }
        
        return lines
    }
    
    /// Get the range of the line containing the given location
    static func lineRange(at location: Int, in text: String) -> NSRange {
        let nsString = text as NSString
        return nsString.lineRange(for: NSRange(location: location, length: 0))
    }
    
    /// Get the content of the line containing the given location
    static func lineContent(at location: Int, in text: String) -> String {
        let nsString = text as NSString
        let range = lineRange(at: location, in: text)
        return nsString.substring(with: range)
    }
    
    /// Check if cursor is at the end of the current line
    static func isAtEndOfLine(cursorPosition: Int, in text: String) -> Bool {
        let nsString = text as NSString
        guard cursorPosition <= nsString.length else { return false }
        
        // At very end of text
        if cursorPosition == nsString.length { return true }
        
        // Check if next character is newline
        let nextChar = nsString.substring(with: NSRange(location: cursorPosition, length: 1))
        return nextChar == "\n"
    }
    
    /// Check if a line contains only a label token (no content after)
    static func isLabelOnlyLine(_ line: String) -> Bool {
        let tokens = LabelTokenParser.findTokens(in: line)
        guard let token = tokens.first else { return false }
        
        // Get content after token
        let nsLine = line as NSString
        let afterToken = token.range.location + token.range.length
        if afterToken >= nsLine.length { return true }
        
        let remaining = nsLine.substring(from: afterToken)
        return remaining.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Custom Attribute Key

extension NSAttributedString.Key {
    static let structuralLabelToken = NSAttributedString.Key("StructuralLabelToken")
}

// MARK: - AttributedTextEditor

struct AttributedTextEditor: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.autocorrectionType = .no
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        
        // Set initial text with styling
        context.coordinator.applyTextWithStyling(text, to: textView)
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        // Only update if text changed externally (not from user typing)
        if textView.text != text {
            let selectedRange = textView.selectedRange
            context.coordinator.applyTextWithStyling(text, to: textView)
            
            // Restore selection if valid
            let maxLocation = (textView.text as NSString).length
            if selectedRange.location <= maxLocation {
                let safeRange = NSRange(
                    location: min(selectedRange.location, maxLocation),
                    length: min(selectedRange.length, maxLocation - min(selectedRange.location, maxLocation))
                )
                textView.selectedRange = safeRange
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        private var isUpdatingText = false
        private var cachedTokens: [LabelToken] = []
        
        init(text: Binding<String>) {
            self.text = text
        }
        
        // MARK: - Styling
        
        func applyTextWithStyling(_ text: String, to textView: UITextView) {
            isUpdatingText = true
            defer { isUpdatingText = false }
            
            let attributedString = NSMutableAttributedString(string: text)
            let fullRange = NSRange(location: 0, length: attributedString.length)
            
            // 1. Base body styling (all text)
            let bodyFont = UIFont.preferredFont(forTextStyle: .body)
            attributedString.addAttribute(.font, value: bodyFont, range: fullRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)
            
            // Find and cache tokens
            cachedTokens = LabelTokenParser.findTokens(in: text)
            let validTokens = cachedTokens.filter { SectionDetector.labelsEnabled(at: $0.range.location, in: text) }
            
            // Enumerate lines for section header and prescription styling
            let lines = LineUtilities.enumerateLines(in: text)
            
            // 2. Prescription line styling (subheadline + secondary) - skip lines with label tokens
            let subheadlineFont = UIFont.preferredFont(forTextStyle: .subheadline)
            for line in lines {
                guard SectionDetector.isPrescriptionLine(line.content) else { continue }
                
                // Skip if line contains a label token
                let hasLabelToken = validTokens.contains { NSIntersectionRange($0.range, line.range).length > 0 }
                if hasLabelToken { continue }
                
                attributedString.addAttribute(.font, value: subheadlineFont, range: line.range)
                attributedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: line.range)
            }
            
            // 3. Section header styling (title3 + semibold)
            let title3Font = UIFont.preferredFont(forTextStyle: .title3)
            let semiboldTitle3Font = UIFontMetrics(forTextStyle: .title3).scaledFont(
                for: UIFont.systemFont(ofSize: title3Font.pointSize, weight: .semibold)
            )
            for line in lines {
                guard SectionDetector.isSectionHeader(line.content) else { continue }
                attributedString.addAttribute(.font, value: semiboldTitle3Font, range: line.range)
            }
            
            // 4. Label token styling (accent @ 0.65 + medium) - overrides prescription if conflict
            let labelFont = UIFont.systemFont(ofSize: bodyFont.pointSize, weight: .medium)
            let labelColor = UIColor.tintColor.withAlphaComponent(0.65)
            
            for token in validTokens {
                attributedString.addAttribute(.font, value: labelFont, range: token.range)
                attributedString.addAttribute(.foregroundColor, value: labelColor, range: token.range)
                attributedString.addAttribute(.structuralLabelToken, value: true, range: token.range)
            }
            
            textView.attributedText = attributedString
        }
        
        private func refreshStyling(in textView: UITextView) {
            let currentText = textView.text ?? ""
            let selectedRange = textView.selectedRange
            applyTextWithStyling(currentText, to: textView)
            
            // Restore selection
            let maxLocation = (textView.text as NSString).length
            if selectedRange.location <= maxLocation {
                textView.selectedRange = NSRange(
                    location: min(selectedRange.location, maxLocation),
                    length: min(selectedRange.length, maxLocation - selectedRange.location)
                )
            }
        }
        
        // MARK: - UITextViewDelegate
        
        func textViewDidChange(_ textView: UITextView) {
            guard !isUpdatingText else { return }
            
            let newText = textView.text ?? ""
            text.wrappedValue = newText
            
            // Refresh styling after change
            refreshStyling(in: textView)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            guard !isUpdatingText else { return }
            
            let currentText = textView.text ?? ""
            let selection = textView.selectedRange
            
            // Only apply caret snapping in label-enabled sections
            guard SectionDetector.labelsEnabled(at: selection.location, in: currentText) else { return }
            
            // Find tokens that might affect selection
            let tokens = cachedTokens.filter { SectionDetector.labelsEnabled(at: $0.range.location, in: currentText) }
            
            if selection.length == 0 {
                // Insertion point - snap to token boundary
                if let token = LabelTokenParser.token(at: selection.location, in: tokens) {
                    // Cursor is inside a token - snap to end of token
                    let tokenEnd = token.range.location + token.range.length
                    if selection.location != tokenEnd && selection.location != token.range.location {
                        isUpdatingText = true
                        textView.selectedRange = NSRange(location: tokenEnd, length: 0)
                        isUpdatingText = false
                    }
                }
            } else {
                // Range selection - expand to include full tokens
                var expandedRange = selection
                var needsExpansion = false
                
                for token in tokens {
                    let intersection = NSIntersectionRange(token.range, selection)
                    if intersection.length > 0 && intersection.length < token.range.length {
                        // Partial intersection - need to expand
                        let unionRange = NSUnionRange(expandedRange, token.range)
                        expandedRange = unionRange
                        needsExpansion = true
                    }
                }
                
                if needsExpansion {
                    isUpdatingText = true
                    textView.selectedRange = expandedRange
                    isUpdatingText = false
                }
            }
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText = textView.text ?? ""
            
            // Only apply special behavior in label-enabled sections
            guard SectionDetector.labelsEnabled(at: range.location, in: currentText) else { return true }
            
            let tokens = cachedTokens.filter { SectionDetector.labelsEnabled(at: $0.range.location, in: currentText) }
            
            // Smart return handling
            if text == "\n" {
                return handleSmartReturn(textView: textView, range: range, tokens: tokens)
            }
            
            // Atomic deletion handling
            if text.isEmpty && range.length > 0 {
                return handleAtomicDeletion(textView: textView, range: range, tokens: tokens)
            }
            
            // Backspace at position right after token
            if text.isEmpty && range.length == 0 {
                // This shouldn't happen normally, but handle edge case
                return true
            }
            
            // Check if trying to type inside a token
            if let token = LabelTokenParser.token(at: range.location, in: tokens) {
                // Allow typing only at the end of the token
                let tokenEnd = token.range.location + token.range.length
                if range.location < tokenEnd && range.location > token.range.location {
                    // Move cursor to end of token and insert there
                    isUpdatingText = true
                    textView.selectedRange = NSRange(location: tokenEnd, length: 0)
                    textView.insertText(text)
                    isUpdatingText = false
                    
                    // Sync and restyle
                    self.text.wrappedValue = textView.text ?? ""
                    refreshStyling(in: textView)
                    return false
                }
            }
            
            return true
        }
        
        // MARK: - Smart Return
        
        private func handleSmartReturn(textView: UITextView, range: NSRange, tokens: [LabelToken]) -> Bool {
            let currentText = textView.text ?? ""
            
            // Check if at end of line
            guard LineUtilities.isAtEndOfLine(cursorPosition: range.location, in: currentText) else {
                return true
            }
            
            // Get current line and check for label
            let lineContent = LineUtilities.lineContent(at: range.location, in: currentText)
            let lineTokens = LabelTokenParser.findTokens(in: lineContent)
            
            guard let lineToken = lineTokens.first else {
                return true // No token on this line, normal return
            }
            
            // Check if this is a "label only" line (exit behavior)
            if LineUtilities.isLabelOnlyLine(lineContent) {
                return true // Just insert newline, no new label
            }
            
            // Insert newline + next label
            let nextToken = lineToken.next()
            let insertText = "\n\(nextToken.text)"
            
            isUpdatingText = true
            textView.insertText(insertText)
            isUpdatingText = false
            
            // Sync and restyle
            text.wrappedValue = textView.text ?? ""
            refreshStyling(in: textView)
            
            return false
        }
        
        // MARK: - Atomic Deletion
        
        private func handleAtomicDeletion(textView: UITextView, range: NSRange, tokens: [LabelToken]) -> Bool {
            // Check if deletion intersects with a token
            guard let token = LabelTokenParser.token(intersecting: range, in: tokens) else {
                return true // No token involved, normal deletion
            }
            
            // Expand deletion to entire token
            let currentText = textView.text ?? ""
            let nsString = currentText as NSString
            
            // Calculate expanded range that includes the full token
            let expandedStart = min(range.location, token.range.location)
            let expandedEnd = max(range.location + range.length, token.range.location + token.range.length)
            let expandedRange = NSRange(location: expandedStart, length: expandedEnd - expandedStart)
            
            // Perform the expanded deletion
            let newText = nsString.replacingCharacters(in: expandedRange, with: "")
            
            isUpdatingText = true
            textView.text = newText
            textView.selectedRange = NSRange(location: expandedStart, length: 0)
            isUpdatingText = false
            
            // Sync and restyle
            text.wrappedValue = newText
            refreshStyling(in: textView)
            
            return false
        }
    }
}

#Preview {
    @Previewable @State var text = """
    Warm Up


    Skill Work
    3 sets • rest TBD
    A1. Pull-ups
    A2. Dips


    Main Work
    3 sets • rest 90s
    B1. Squats
    B2. RDL

    Notes
    Some notes here
    """
    
    AttributedTextEditor(text: $text)
        .padding()
}

