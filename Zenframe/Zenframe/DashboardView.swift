//
//  DashboardView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        TabView {
            HomePage()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            BookmarksPage()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark.fill")
                }

            JournalPage()
                .tabItem {
                    Label("Journal", systemImage: "book.closed.fill")
                }

            ProfilePage()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
    }
}

#Preview {
    DashboardView()
}

