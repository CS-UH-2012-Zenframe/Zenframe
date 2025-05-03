//
//  ContactRow.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 03/05/2025.
//
import SwiftUI

struct ContactRow: View {
    let title: String
    let detail: String
    let action: String
    let color: Color

    @State private var showConfirmation = false
    @State private var showError = false
    @State private var goToSelfSupport = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .fontWeight(.semibold)

            Text(detail)
                .foregroundColor(.black.opacity(0.7))

            HStack {
                Spacer()
                Button(action: {
                    showConfirmation = true
                }) {
                    Text(action)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color)
                        .cornerRadius(20)
                }
                .alert("Confirm", isPresented: $showConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button(action == "TEXT NOW" ? "Text" : "Call") {
                        performAction()
                    }
                } message: {
                    Text("Do you want to \(action.lowercased()) \(detail)?")
                }
            }

            // Hidden navigation trigger
            NavigationLink(destination: SelfSupportView(), isActive: $goToSelfSupport) {
                EmptyView()
            }
        }
        .padding()
        .background(Color.white.opacity(0.3))
        .cornerRadius(15)
        .alert("Unable to complete the action", isPresented: $showError) {
            Button("Go to Self Support", role: .cancel) {
                goToSelfSupport = true
            }
        } message: {
            Text("Try visiting the Self Support page for more help.")
        }
    }

    func performAction() {
        incrementTapCount(for: title)

        if title.contains("Text") {
            let sms = "sms:741741&body=HOME"
            openURL(sms)
        } else if title.contains("Teen Line") {
            showError = true
        } else {
            let number = detail.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let tel = "tel://\(number)"
            openURL(tel)
        }
    }

    func openURL(_ urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showError = true
        }
    }

    func incrementTapCount(for key: String) {
        let fullKey = "contactTapCount_\(key)"
        let current = UserDefaults.standard.integer(forKey: fullKey)
        UserDefaults.standard.set(current + 1, forKey: fullKey)
    }
}
