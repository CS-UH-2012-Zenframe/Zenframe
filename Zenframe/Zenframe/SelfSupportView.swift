//
//  SelfSupportView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 17/04/2025.
//

import SwiftUI

struct SelfSupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("SELF SUPPORT")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("You're doing great by taking a moment for yourself.")
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.bottom)

                // Breathing Exercise
                VStack(alignment: .leading, spacing: 10) {
                    Text("🧘‍♀️ Breathing Exercise")
                        .font(.headline)

                    Text("Try box breathing:\n\n• Inhale for 4 seconds\n• Hold for 4 seconds\n• Exhale for 4 seconds\n• Hold for 4 seconds\n\nRepeat this for a few minutes to calm your nervous system.")
                        .font(.body)
                        .foregroundColor(.black.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(15)

                // Grounding Exercise
                VStack(alignment: .leading, spacing: 10) {
                    Text("🌱 Grounding Technique")
                        .font(.headline)

                    Text("Use the 5-4-3-2-1 method:\n\n• 5 things you can see\n• 4 things you can touch\n• 3 things you can hear\n• 2 things you can smell\n• 1 thing you can taste\n\nFocus your attention on the present moment.")
                        .font(.body)
                        .foregroundColor(.black.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(15)

                // Affirmations
                VStack(alignment: .leading, spacing: 10) {
                    Text("💬 Positive Affirmations")
                        .font(.headline)

                    Text("• I am safe in this moment.\n• I am doing the best I can.\n• I am strong and capable.\n• I have overcome challenges before.")
                        .font(.body)
                        .foregroundColor(.black.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(15)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Self Support")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("ZenGreen").ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        SelfSupportView()
    }
}
