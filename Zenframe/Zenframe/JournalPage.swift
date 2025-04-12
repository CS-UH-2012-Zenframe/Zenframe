//
//  JournalPage.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//
import SwiftUI

struct JournalPage: View {
    @State private var entry: String = ""
    @State private var isSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What's on your mind?")
                .font(.title2)
                .fontWeight(.semibold)

            ZStack(alignment: .topLeading) {
                if entry.isEmpty {
                    Text("Write something here...")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .opacity(0.8)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: entry)
                }

                TextEditor(text: $entry)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .frame(height: 200)
            }

            Button(action: {
                isSaved = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isSaved = false
                }
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSaved ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(.easeInOut, value: isSaved)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    JournalPage()
}
