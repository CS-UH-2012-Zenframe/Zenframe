//
//  ZenframeApp.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 09/04/2025.
//

import SwiftUI

@main
struct ZenframeApp: App {
    @StateObject private var sessionStore = SessionStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
        }
    }
}
