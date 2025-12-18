//
//  DatabaseErrorView.swift
//  notes-workout-log
//
//  Created by Marcelo Albuquerque on 18/12/25.
//

import SwiftUI

struct DatabaseErrorView: View {
    let error: Error
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.orange)
            
            Text("Unable to Load Data")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("The app couldn't access your notes. Please try restarting the app.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                showDetails.toggle()
            } label: {
                HStack {
                    Text("Technical Details")
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            if showDetails {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DatabaseErrorView(error: NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sample error for preview"]))
}

