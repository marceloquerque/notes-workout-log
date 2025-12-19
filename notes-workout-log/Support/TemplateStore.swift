//
//  TemplateStore.swift
//  notes-workout-log
//

import Foundation

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
}

