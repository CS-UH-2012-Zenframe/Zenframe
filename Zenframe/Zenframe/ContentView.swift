//
//  ContentView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 09/04/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        NavigationStack {
            if sessionStore.isAuthenticated {
                DashboardView()
                    .environmentObject(sessionStore)
            } else {
                StartingPage()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionStore())
}
