//
//  LabelTokenTests.swift
//  notes-workout-logTests
//

import XCTest
@testable import notes_workout_log

final class LabelTokenTests: XCTestCase {
    
    // MARK: - Token Parsing Tests
    
    func testFindsTokenAtLineStart() {
        let text = "A1. Squats"
        let tokens = LabelTokenParser.findTokens(in: text)
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first?.letter, "A")
        XCTAssertEqual(tokens.first?.number, 1)
    }
    
    func testFindsMultipleTokens() {
        let text = """
        A1. Squats
        A2. Deadlift
        B1. Bench
        """
        let tokens = LabelTokenParser.findTokens(in: text)
        
        XCTAssertEqual(tokens.count, 3)
        XCTAssertEqual(tokens[0].letter, "A")
        XCTAssertEqual(tokens[0].number, 1)
        XCTAssertEqual(tokens[1].letter, "A")
        XCTAssertEqual(tokens[1].number, 2)
        XCTAssertEqual(tokens[2].letter, "B")
        XCTAssertEqual(tokens[2].number, 1)
    }
    
    func testIgnoresMidLineTokens() {
        let text = "Some text A1. not at start"
        let tokens = LabelTokenParser.findTokens(in: text)
        
        XCTAssertTrue(tokens.isEmpty)
    }
    
    func testIgnoresLowercaseTokens() {
        let text = "a1. lowercase"
        let tokens = LabelTokenParser.findTokens(in: text)
        
        XCTAssertTrue(tokens.isEmpty)
    }
    
    func testIgnoresZeroNumber() {
        let text = "A0. zero"
        let tokens = LabelTokenParser.findTokens(in: text)
        
        XCTAssertTrue(tokens.isEmpty)
    }
    
    func testIgnoresMultiLetterPrefix() {
        let text = "AA1. double letter"
        let tokens = LabelTokenParser.findTokens(in: text)
        
        XCTAssertTrue(tokens.isEmpty)
    }
    
    func testIgnoresMissingSpace() {
        let text = "A1.NoSpace"
        let tokens = LabelTokenParser.findTokens(in: text)
        
        XCTAssertTrue(tokens.isEmpty)
    }
    
    func testLargeNumbers() {
        let text = "Z99. large number"
        let tokens = LabelTokenParser.findTokens(in: text)
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first?.letter, "Z")
        XCTAssertEqual(tokens.first?.number, 99)
    }
    
    // MARK: - Next Label Calculation Tests
    
    func testNextLabelIncrementsNumber() {
        let token = LabelToken(letter: "A", number: 1, range: NSRange(location: 0, length: 4))
        let next = token.next()
        
        XCTAssertEqual(next.letter, "A")
        XCTAssertEqual(next.number, 2)
        XCTAssertEqual(next.text, "A2. ")
    }
    
    func testNextLabelFromLargeNumber() {
        let token = LabelToken(letter: "Z", number: 9, range: NSRange(location: 0, length: 4))
        let next = token.next()
        
        XCTAssertEqual(next.letter, "Z")
        XCTAssertEqual(next.number, 10)
        XCTAssertEqual(next.text, "Z10. ")
    }
    
    func testNextLabelPreservesLetter() {
        let token = LabelToken(letter: "C", number: 3, range: NSRange(location: 0, length: 4))
        let next = token.next()
        
        XCTAssertEqual(next.letter, "C")
        XCTAssertEqual(next.number, 4)
    }
    
    // MARK: - Section Detection Tests
    
    func testDetectsSkillWorkSection() {
        let text = """
        Warm Up
        
        Skill Work
        A1. Pull-ups
        """
        let cursorPosition = (text as NSString).length
        let section = SectionDetector.currentSection(at: cursorPosition, in: text)
        
        XCTAssertEqual(section, .skillWork)
        XCTAssertTrue(SectionDetector.labelsEnabled(at: cursorPosition, in: text))
    }
    
    func testDetectsMainWorkSection() {
        let text = """
        Skill Work
        A1. Something
        
        Main Work
        B1. Squats
        """
        let cursorPosition = (text as NSString).length
        let section = SectionDetector.currentSection(at: cursorPosition, in: text)
        
        XCTAssertEqual(section, .mainWork)
        XCTAssertTrue(SectionDetector.labelsEnabled(at: cursorPosition, in: text))
    }
    
    func testLabelsDisabledInWarmUp() {
        let text = """
        Warm Up
        Some warmup exercises
        """
        let cursorPosition = (text as NSString).length
        
        XCTAssertFalse(SectionDetector.labelsEnabled(at: cursorPosition, in: text))
    }
    
    func testLabelsDisabledInNotes() {
        let text = """
        Main Work
        B1. Squats
        
        Notes
        Some notes here
        """
        let cursorPosition = (text as NSString).length
        
        XCTAssertFalse(SectionDetector.labelsEnabled(at: cursorPosition, in: text))
    }
    
    func testSectionDetectionCaseInsensitive() {
        let text = """
        SKILL WORK
        A1. Pull-ups
        """
        let cursorPosition = (text as NSString).length
        
        XCTAssertTrue(SectionDetector.labelsEnabled(at: cursorPosition, in: text))
    }
    
    func testSectionDetectionTrimsWhitespace() {
        let text = """
          Skill Work  
        A1. Pull-ups
        """
        let cursorPosition = (text as NSString).length
        
        XCTAssertTrue(SectionDetector.labelsEnabled(at: cursorPosition, in: text))
    }
    
    // MARK: - Line Utility Tests
    
    func testIsLabelOnlyLineTrue() {
        XCTAssertTrue(LineUtilities.isLabelOnlyLine("A1. "))
        XCTAssertTrue(LineUtilities.isLabelOnlyLine("A1. \n"))
        XCTAssertTrue(LineUtilities.isLabelOnlyLine("B2.   \n"))
    }
    
    func testIsLabelOnlyLineFalse() {
        XCTAssertFalse(LineUtilities.isLabelOnlyLine("A1. Squats"))
        XCTAssertFalse(LineUtilities.isLabelOnlyLine("A1. x"))
        XCTAssertFalse(LineUtilities.isLabelOnlyLine("No label here"))
    }
    
    func testIsAtEndOfLine() {
        let text = "Line 1\nLine 2\n"
        
        // End of Line 1 (position 6, before \n)
        XCTAssertTrue(LineUtilities.isAtEndOfLine(cursorPosition: 6, in: text))
        
        // End of text
        XCTAssertTrue(LineUtilities.isAtEndOfLine(cursorPosition: 14, in: text))
        
        // Middle of Line 1
        XCTAssertFalse(LineUtilities.isAtEndOfLine(cursorPosition: 3, in: text))
    }
    
    // MARK: - Token Location Tests
    
    func testTokenAtLocation() {
        let tokens = [
            LabelToken(letter: "A", number: 1, range: NSRange(location: 0, length: 4)),
            LabelToken(letter: "A", number: 2, range: NSRange(location: 20, length: 4))
        ]
        
        // Inside first token
        XCTAssertEqual(LabelTokenParser.token(at: 2, in: tokens)?.number, 1)
        
        // Inside second token
        XCTAssertEqual(LabelTokenParser.token(at: 22, in: tokens)?.number, 2)
        
        // Outside tokens
        XCTAssertNil(LabelTokenParser.token(at: 10, in: tokens))
    }
    
    func testTokenIntersectingRange() {
        let tokens = [
            LabelToken(letter: "A", number: 1, range: NSRange(location: 0, length: 4))
        ]
        
        // Range fully inside token
        let inside = LabelTokenParser.token(intersecting: NSRange(location: 1, length: 2), in: tokens)
        XCTAssertNotNil(inside)
        
        // Range partially overlapping
        let partial = LabelTokenParser.token(intersecting: NSRange(location: 2, length: 5), in: tokens)
        XCTAssertNotNil(partial)
        
        // Range outside token
        let outside = LabelTokenParser.token(intersecting: NSRange(location: 10, length: 2), in: tokens)
        XCTAssertNil(outside)
    }
}

