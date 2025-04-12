//
//  ProfilePage.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//

//import SwiftUI
//
//struct ProfilePage: View {
//    var body: some View {
//        VStack {
//            Text("Profile")
//                .font(.title)
//                .bold()
//            // Add toggles, preferences, logout button, etc.
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    ProfilePage()
//}


import SwiftUI

struct ProfilePage: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding()

                    Text("User: Asgar Fataymamode")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Email: asgar@gmail.com")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Divider()

                    NavigationLink(destination: EditProfileView()) {
                        profileButtonLabel("Edit Profile")
                    }

                    NavigationLink(destination: AboutView()) {
                        profileButtonLabel("About")
                    }

                    NavigationLink(destination: RulesAndRegulationsView()) {
                        profileButtonLabel("Rules & Regulations")
                    }

                    NavigationLink(destination: SettingsView()) {
                        profileButtonLabel("Settings")
                    }

                    Divider()

                    Button(action: {
                        // log out action
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func profileButtonLabel(_ title: String) -> some View {
        Text(title)
            .foregroundColor(.blue)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 20)
    }
}

#Preview {
    ProfilePage()
}
