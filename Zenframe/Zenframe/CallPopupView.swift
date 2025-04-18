//
//  CallPopupView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 18/04/2025.
//

import SwiftUI

struct CallPopupView: View {
    let title: String
    @State private var sliderValue: Double = 0.0
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 30) {
            Text("Calling \(title)")
                .font(.title2)
                .bold()
                .padding(.top)

            Text("Slide to confirm call")
                .foregroundColor(.gray)

            Slider(value: $sliderValue, in: 0...100)
                .accentColor(.red)
                .padding()
                .onChange(of: sliderValue) {
                    if sliderValue >= 100 {
                        dismiss()
                    }
                }

            Text("Call")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
}
