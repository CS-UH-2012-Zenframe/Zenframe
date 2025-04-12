//
//  AboutView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("About This App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Text("Zenframe is a mental health-focused news app designed to filter, personalize, and rephrase news content in ways that promote emotional well-being. The app uses AI to summarize news in nonviolent, less sensationalized language while offering tools for mood tracking, relaxation, and community engagement. Built with SwiftUI.")
                    .font(.body)
                    .padding()

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Features:")
                        .font(.headline)

                    Text("• Filter news by Positivity")
                    Text("• Rephrase news in a more neutral manner")
                    Text("• Bookmark interesting news articles")
                    Text("• Add your comments to news articles")
                    Text("• Write your thoughts in a journal")
                    Text("• Use our mental health resources")
                }
                .padding()

                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AboutView()
}
