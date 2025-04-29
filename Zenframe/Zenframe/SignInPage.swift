//
//  SignInPage.swift
//  Zenframe
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//

import SwiftUI

struct SignInPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // ❗️ NEW
    @State private var navigateToDashboard = false
    
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.title)
                .bold()

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
                Task { await signIn() }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Log In")
                }
            }
            .disabled(isLoading || !isFormValid)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isFormValid ? Color.blue : Color.blue.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .disabled(isLoading)
        
        // ❗️ Navigation trigger (needs a NavigationStack higher up)
        .navigationDestination(isPresented: $navigateToDashboard) {
            DashboardView()
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    private func signIn() async {
        await MainActor.run {           // keep UI updates on main thread
            isLoading = true
            errorMessage = nil
        }
        do {
            try await sessionStore.signIn(email: email, password: password)
            
            // ❗️ Successful → route to dashboard
            await MainActor.run {
                navigateToDashboard = true
            }
        } catch let apiError as APIService.APIError {
            await MainActor.run {
                errorMessage = apiError.errorDescription
            }
        } catch {
            await MainActor.run {
                errorMessage = "Login failed: \(error.localizedDescription)"
            }
        }
        await MainActor.run {
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {                  // ❗️ Make sure a NavigationStack exists
        SignInPage()
            .environmentObject(SessionStore())
    }
}
