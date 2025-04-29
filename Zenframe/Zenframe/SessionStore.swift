import Foundation
import SwiftUI

@MainActor
class SessionStore: ObservableObject {
    @Published var token: String?
    @Published var userEmail: String?
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var isAuthenticated: Bool = false
    
    init() {
        self.token = UserDefaults.standard.string(forKey: "access_token")
        self.userEmail = UserDefaults.standard.string(forKey: "user_email")
        self.firstName = UserDefaults.standard.string(forKey: "user_first_name")
        self.lastName = UserDefaults.standard.string(forKey: "user_last_name")
        self.isAuthenticated = self.token != nil
    }
    
    func signIn(email: String, password: String) async throws {
        let authResponse = try await APIService.shared.login(email: email, password: password)
        self.token = authResponse.access_token
        self.userEmail = email
        self.isAuthenticated = true
        
        // Try to fetch user profile
        do {
            let profile = try await APIService.shared.getUserProfile()
            self.firstName = profile.first_name
            self.lastName = profile.last_name
            UserDefaults.standard.set(profile.first_name, forKey: "user_first_name")
            UserDefaults.standard.set(profile.last_name, forKey: "user_last_name")
        } catch {
            print("Could not load user profile, using stored info")
        }
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async throws {
        let authResponse = try await APIService.shared.signup(email: email, password: password, firstName: firstName, lastName: lastName)
        self.token = authResponse.access_token
        self.userEmail = email
        self.firstName = firstName
        self.lastName = lastName
        self.isAuthenticated = true
    }
    
    func signOut() {
        self.token = nil
        self.userEmail = nil
        self.firstName = nil
        self.lastName = nil
        self.isAuthenticated = false
        
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "user_first_name")
        UserDefaults.standard.removeObject(forKey: "user_last_name")
    }
} 