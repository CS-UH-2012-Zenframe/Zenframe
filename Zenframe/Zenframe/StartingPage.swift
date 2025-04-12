//
//  StartingPage.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//

import SwiftUI

struct StartingPage: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Welcome to Zenframe")
                    .font(.largeTitle)
                    .bold()
                
                NavigationLink(destination: SignInPage()) {
                    Text("Sign In")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: SignUpPage()) {
                    Text("Sign Up")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

#Preview {
    StartingPage()
}
