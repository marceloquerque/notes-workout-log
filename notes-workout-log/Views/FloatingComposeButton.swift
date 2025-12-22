//
//  FloatingComposeButton.swift
//  notes-workout-log
//
//  Floating action button for creating new notes, matching iOS Notes design.
//

import SwiftUI

struct FloatingComposeButton: View {
    let onCompose: () -> Void
    var isEnabled: Bool = true
    var isVisible: Bool = true
    
    var body: some View {
        if isVisible {
            Button(action: onCompose) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 24, weight: .medium))
            }
            .frame(width: 56, height: 56)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1.0 : 0.5)
            .accessibilityLabel("New Note")
            .accessibilityHint("Creates a new note")
        }
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        FloatingComposeButton(onCompose: {})
            .padding(.trailing, 20)
            .padding(.bottom, 20)
    }
}

