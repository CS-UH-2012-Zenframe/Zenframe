//
//  SignInPage.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//
//
//import SwiftUI
//
//struct SignInPage: View {
//    @State private var email = ""
//    @State private var password = ""
//    @State private var navigateToDashboard = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Sign In")
//                .font(.title)
//                .bold()
//
//            TextField("Email", text: $email)
//                .keyboardType(.emailAddress)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//
//            SecureField("Password", text: $password)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//
//            Button("Log In") {
//                navigateToDashboard = true
//                
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//            
//            
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    SignInPage()
//}

import SwiftUI

struct SignInPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToDashboard = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.title)
                .bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Log In") {
                // Simulate login
                navigateToDashboard = true
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .navigationDestination(isPresented: $navigateToDashboard) {
            DashboardView()
        }
    }
}

#Preview {
    NavigationStack {
        SignInPage()
    }
}
