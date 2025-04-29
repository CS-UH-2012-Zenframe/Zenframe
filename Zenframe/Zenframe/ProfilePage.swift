import SwiftUI

struct ProfilePage: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    // NAV FLAG -> pushes to StartingPage after sign-out
    @State private var gotoStart = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)

                Text(fullName)
                    .font(.title2).bold()

                if let email = sessionStore.userEmail {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Divider()

                // rows
                NavigationLink(destination: AboutView())                  { profileRow("About") }
                NavigationLink(destination: RulesAndRegulationsView())    { profileRow("Rules & Regulations") }
                NavigationLink(destination: SettingsView())               { profileRow("Settings") }

                Divider()

                // LOG-OUT → clear creds & trigger nav
                Button(role: .destructive) {
                    sessionStore.signOut()
                    gotoStart = true
                } label: {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        // pushes StartingPage once gotoStart flips
        .navigationDestination(isPresented: $gotoStart) {
            StartingPage().environmentObject(sessionStore)
        }
    }

    // MARK: – helpers
    private var fullName: String {
        [sessionStore.firstName, sessionStore.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
            .ifEmpty("User Profile")
    }

    private func profileRow(_ title: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// tiny utility
private extension String {
    func ifEmpty(_ fallback: String) -> String { isEmpty ? fallback : self }
}
