//
//  Folder.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import Foundation

struct Folder: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    let isSystemFolder: Bool
    
    init(id: UUID = UUID(), name: String, isSystemFolder: Bool = false) {
        self.id = id
        self.name = name
        self.isSystemFolder = isSystemFolder
    }
}

