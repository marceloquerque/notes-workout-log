//
//  FoldersViewModel.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import Foundation
import SwiftUI

@Observable
final class FoldersViewModel {
    var folders: [Folder] = []
    var searchText: String = ""
    
    private let foldersKey = "savedFolders"
    
    init() {
        loadFolders()
        if folders.isEmpty {
            createDefaultFolder()
        }
    }
    
    var filteredFolders: [Folder] {
        if searchText.isEmpty {
            return folders
        }
        return folders.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    func createFolder(name: String) {
        let folder = Folder(name: name)
        folders.append(folder)
        saveFolders()
    }
    
    func deleteFolder(_ folder: Folder) {
        folders.removeAll { $0.id == folder.id }
        saveFolders()
    }
    
    private func createDefaultFolder() {
        let defaultFolder = Folder(name: "Notes", isSystemFolder: false)
        folders.append(defaultFolder)
        saveFolders()
    }
    
    private func loadFolders() {
        guard let data = UserDefaults.standard.data(forKey: foldersKey),
              let decoded = try? JSONDecoder().decode([Folder].self, from: data) else {
            return
        }
        folders = decoded
    }
    
    private func saveFolders() {
        guard let encoded = try? JSONEncoder().encode(folders) else {
            return
        }
        UserDefaults.standard.set(encoded, forKey: foldersKey)
    }
}

