//
//  EditProfileView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//

import SwiftUI

struct EditProfileView: View {
    @State private var name: String = ""
    @State private var email: String = ""

    var body: some View {
        Form {
            Section(header: Text("User Info")) {
                TextField("Full Name", text: $name)
                TextField("Email", text: $email)
            }

            Section {
                Button("Save Changes") {
                    // Save logic
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    EditProfileView()
}
