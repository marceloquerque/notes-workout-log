//
//  TemplateStore.swift
//  notes-workout-log
//

import Foundation

@Observable
final class TemplateStore {
    var templates: [WorkoutTemplate]
    
    // swiftlint:disable:next line_length
    private static let workoutTemplateContent = "Warm Up\n\n\n\nMobility\n\n\n\nSkill Work\n3 sets • rest TBD\nA1. \nA2. \n\n\n\nMain Work\n3 sets • rest 90s\nA1. \nA2. \n\n3 sets • rest 60s\nB1. \nB2. \n\n2-3 sets • rest 30-60s\nC1. \nC2. \nC3. \n\n\n\nCool Down\n\n\n\nNotes\n"
    
    init() {
        self.templates = [
            WorkoutTemplate(
                id: "upper",
                name: "Upper",
                content: Self.workoutTemplateContent
            ),
            WorkoutTemplate(
                id: "lower",
                name: "Lower",
                content: Self.workoutTemplateContent
            ),
            WorkoutTemplate(
                id: "full_body",
                name: "Full Body",
                content: "Full Body\n\n"
            )
        ]
    }
}

