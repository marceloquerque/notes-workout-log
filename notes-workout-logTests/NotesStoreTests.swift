//
//  NotesStoreTests.swift
//  notes-workout-logTests
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import XCTest
import SwiftData
@testable import notes_workout_log

@MainActor
final class NotesStoreTests: XCTestCase {
    var container: ModelContainer!
    var store: NotesStore!
    
    override func setUpWithError() throws {
        let schema = Schema([Folder.self, Note.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        store = NotesStore(modelContext: container.mainContext)
    }
    
    override func tearDownWithError() throws {
        container = nil
        store = nil
    }
    
    // MARK: - Folder Tests
    
    func testCreateFolder() throws {
        let folder = store.createFolder(name: "Test Folder")
        
        XCTAssertNotNil(folder)
        XCTAssertEqual(folder?.name, "Test Folder")
        XCTAssertFalse(folder?.isSystemFolder ?? true)
        
        let descriptor = FetchDescriptor<Folder>()
        let folders = try container.mainContext.fetch(descriptor)
        // Default folder is created on init + our test folder
        XCTAssertEqual(folders.count, 2)
    }
    
    func testDeleteFolder() throws {
        let folder = store.createFolder(name: "To Delete")
        XCTAssertNotNil(folder)
        
        let descriptor = FetchDescriptor<Folder>(
            predicate: #Predicate { $0.name == "To Delete" }
        )
        var folders = try container.mainContext.fetch(descriptor)
        XCTAssertEqual(folders.count, 1)
        
        store.deleteFolder(folder!)
        
        folders = try container.mainContext.fetch(descriptor)
        XCTAssertEqual(folders.count, 0)
    }
    
    func testRenameFolder() throws {
        let folder = store.createFolder(name: "Original Name")
        XCTAssertNotNil(folder)
        
        store.renameFolder(folder!, to: "New Name")
        
        XCTAssertEqual(folder?.name, "New Name")
    }
    
    // MARK: - Note Tests
    
    func testCreateNote() throws {
        let folder = store.createFolder(name: "Notes Folder")
        XCTAssertNotNil(folder)
        
        let note = store.createNote(in: folder!)
        
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.folder?.id, folder?.id)
        XCTAssertEqual(note?.title, "")
        XCTAssertEqual(note?.content, "")
    }
    
    func testDeleteNote() throws {
        let folder = store.createFolder(name: "Notes Folder")!
        let note = store.createNote(in: folder)!
        
        let descriptor = FetchDescriptor<Note>()
        var notes = try container.mainContext.fetch(descriptor)
        XCTAssertEqual(notes.count, 1)
        
        store.deleteNote(note)
        
        notes = try container.mainContext.fetch(descriptor)
        XCTAssertEqual(notes.count, 0)
    }
    
    func testUpdateNoteContent() throws {
        let folder = store.createFolder(name: "Notes Folder")!
        let note = store.createNote(in: folder)!
        let originalUpdatedAt = note.updatedAt
        
        // Small delay to ensure updatedAt changes
        Thread.sleep(forTimeInterval: 0.01)
        
        store.updateNoteContent(note, content: "Updated content")
        store.save()
        
        XCTAssertEqual(note.content, "Updated content")
        XCTAssertGreaterThan(note.updatedAt, originalUpdatedAt)
    }
    
    func testMoveNote() throws {
        let folder1 = store.createFolder(name: "Folder 1")!
        let folder2 = store.createFolder(name: "Folder 2")!
        let note = store.createNote(in: folder1)!
        
        XCTAssertEqual(note.folder?.id, folder1.id)
        
        store.moveNote(note, to: folder2)
        
        XCTAssertEqual(note.folder?.id, folder2.id)
    }
    
    // MARK: - Cascade Delete Tests
    
    func testDeleteFolderCascadesNotes() throws {
        let folder = store.createFolder(name: "Folder With Notes")!
        
        _ = store.createNote(in: folder)
        _ = store.createNote(in: folder)
        _ = store.createNote(in: folder)
        
        let noteDescriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.folder?.id == folder.id }
        )
        var notes = try container.mainContext.fetch(noteDescriptor)
        XCTAssertEqual(notes.count, 3)
        
        store.deleteFolder(folder)
        
        notes = try container.mainContext.fetch(noteDescriptor)
        XCTAssertEqual(notes.count, 0)
    }
    
    // MARK: - Title Tests
    
    func testDisplayTitleDefaultsToNewNote() throws {
        let folder = store.createFolder(name: "Test")!
        let note = store.createNote(in: folder)!
        
        XCTAssertEqual(note.title, "")
        XCTAssertEqual(note.displayTitle, AppStrings.newNoteTitle)
    }
    
    func testDisplayTitleReturnsTrimmedTitle() throws {
        let folder = store.createFolder(name: "Test")!
        let note = store.createNote(in: folder)!
        
        store.updateNoteTitle(note, title: "  My Title  ")
        XCTAssertEqual(note.displayTitle, "My Title")
    }
    
    func testUpdateTitleDoesNotChangeContent() throws {
        let folder = store.createFolder(name: "Test")!
        let note = store.createNote(in: folder)!
        
        store.updateNoteContent(note, content: "Some content")
        store.updateNoteTitle(note, title: "My Title")
        
        XCTAssertEqual(note.title, "My Title")
        XCTAssertEqual(note.content, "Some content")
    }
    
    func testUpdateNoteTitle() throws {
        let folder = store.createFolder(name: "Test")!
        let note = store.createNote(in: folder)!
        let originalUpdatedAt = note.updatedAt
        
        Thread.sleep(forTimeInterval: 0.01)
        
        store.updateNoteTitle(note, title: "New Title")
        store.save()
        
        XCTAssertEqual(note.title, "New Title")
        XCTAssertGreaterThan(note.updatedAt, originalUpdatedAt)
    }
    
    // MARK: - Preview Tests
    
    func testNotePreview() throws {
        let folder = store.createFolder(name: "Test")!
        let note = store.createNote(in: folder)!
        
        XCTAssertEqual(note.preview, "")
        
        store.updateNoteContent(note, content: "First line\nSecond line\nThird line")
        XCTAssertEqual(note.preview, "First line Second line")
        
        store.updateNoteContent(note, content: "Only one line")
        XCTAssertEqual(note.preview, "Only one line")
    }
    
    func testNotePreviewSkipsEmptyLines() throws {
        let folder = store.createFolder(name: "Test")!
        let note = store.createNote(in: folder)!
        
        store.updateNoteContent(note, content: "  \nActual content\nMore content")
        XCTAssertEqual(note.preview, "Actual content More content")
    }
    
    // MARK: - Default Folder Tests
    
    func testDefaultFolderCreatedOnInit() throws {
        let defaultFolderName = AppStrings.defaultFolderName
        let descriptor = FetchDescriptor<Folder>(
            predicate: #Predicate { $0.name == defaultFolderName }
        )
        let folders = try container.mainContext.fetch(descriptor)
        XCTAssertEqual(folders.count, 1)
    }
    
    // MARK: - Error Handling Tests
    
    func testNoAlertOnSuccessfulOperations() throws {
        XCTAssertNil(store.alert)
        
        _ = store.createFolder(name: "Test")
        XCTAssertNil(store.alert)
    }
}

