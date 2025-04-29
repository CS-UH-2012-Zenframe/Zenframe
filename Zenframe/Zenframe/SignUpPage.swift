//
//  SignUpPage.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//

import SwiftUI

struct SignUpPage: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.title)
                .bold()
            
            TextField("First Name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Last Name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
            
            Button(action: {
                Task {
                    await signUp()
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Create Account")
                }
            }
            .disabled(isLoading || !isFormValid)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isFormValid ? Color.green : Color.green.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .disabled(isLoading)
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && password.count >= 6
    }
    
    private func signUp() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fullName = "\(firstName) \(lastName)"
            try await sessionStore.signUp(email: email, password: password, firstName: firstName, lastName: lastName)
        } catch let error as APIService.APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Signup failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    SignUpPage()
        .environmentObject(SessionStore())
}
