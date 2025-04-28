//
//  SignInPage.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//

import SwiftUI

struct SignInPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToDashboard = false
    @State private var errorMessage: String? = nil

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
                if email.lowercased() == "absera@gmail.com" && password == "absera" {
                    navigateToDashboard = true
                    errorMessage = nil
                } else {
                    errorMessage = "Invalid Credentials"
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            // Show error message if credentials are incorrect
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
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
//                // Simulate login
//                navigateToDashboard = true
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//        }
//        .padding()
//        .navigationDestination(isPresented: $navigateToDashboard) {
//            DashboardView()
//        }
//    }
//}
//
//#Preview {
//    NavigationStack {
//        SignInPage()
//    }
//}


