//
//  RulesAndRegulationsView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//

import SwiftUI

struct RulesAndRegulationsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Rules and Regulations")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Group {
                    Text("1. Be respectful to other users.")
                    Text("2. Keep your content appropriate.")
                    Text("3. Violating rules may lead to a ban.")
                }
                .font(.body)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Rules & Regulations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RulesAndRegulationsView()
}
