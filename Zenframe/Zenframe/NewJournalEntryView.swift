//
//  NewJournalEntryView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 05/05/2025.
//

import SwiftUI

struct NewJournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var entryText = ""

    var onSave: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("New Entry")
                    .font(.title2)
                    .bold()

                TextEditor(text: $entryText)
                    .padding()
                    .frame(height: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !entryText.trimmingCharacters(in: .whitespaces).isEmpty {
                            onSave(entryText)
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}