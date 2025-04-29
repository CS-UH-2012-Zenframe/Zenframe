//
//  DashboardView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        TabView {
            NavigationStack {
                HomePage()
                    .environmentObject(sessionStore)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                BookmarksPage()
            }
            .tabItem {
                Label("Bookmarks", systemImage: "bookmark.fill")
            }

            NavigationStack {
                JournalPage()
            }
            .tabItem {
                Label("Journal", systemImage: "book.closed.fill")
            }

            NavigationStack {
                ProfilePage()
                    .environmentObject(sessionStore)
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }

            NavigationStack {
                CrisisSupportView()
            }
            .tabItem {
                Label("Crisis", systemImage: "exclamationmark.triangle.fill")
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(SessionStore())
}



//import SwiftUI
//
//struct DashboardView: View {
//    var body: some View {
//        TabView {
//            HomePage()
//                .tabItem {
//                    Label("Home", systemImage: "house.fill")
//                }
//
//            BookmarksPage()
//                .tabItem {
//                    Label("Bookmarks", systemImage: "bookmark.fill")
//                }
//
//            JournalPage()
//                .tabItem {
//                    Label("Journal", systemImage: "book.closed.fill")
//                }
//
//            ProfilePage()
//                .tabItem {
//                    Label("Profile", systemImage: "person.crop.circle.fill")
//                }
//        }
//    }
//}
//
//#Preview {
//    DashboardView()
//}

