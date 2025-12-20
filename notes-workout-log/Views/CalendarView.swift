//
//  CalendarView.swift
//  notes-workout-log
//
//  Placeholder view for the Calendar tab.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Calendar")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Coming soon")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    CalendarView()
}

