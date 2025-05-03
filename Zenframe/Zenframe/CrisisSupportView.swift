//
//  CrisisSupportView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 17/04/2025.
//
//
//import SwiftUI
//
//struct CrisisSupportView: View {
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                Text("CRISIS SUPPORT")
//                    .font(.title2)
//                    .fontWeight(.bold)
//
////                Text("Stay informed, stay calm.")
////                    .foregroundColor(.black.opacity(0.7))
//
//                Text("You are not alone. Help is available!!")
//                    .fontWeight(.medium)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.white.opacity(0.5))
//                    .cornerRadius(20)
//
//                Text("List of Contacts")
//                    .font(.headline)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                ContactRow(title: "National Suicide Prevention Lifeline", detail: "998", action: "CALL NOW", color: .red)
//                ContactRow(title: "Crisis Text Line", detail: "Text HOME to 741741", action: "TEXT NOW", color: .yellow)
//                ContactRow(title: "The National Domestic Violence Hotline", detail: "1-800-799-SAFE (7233)", action: "CALL NOW", color: .red)
//                ContactRow(title: "Teen Line (Support by Teens, for Teens)", detail: "1-800-852-833", action: "CALL NOW", color: .red)
//
//                Spacer()
//
//                NavigationLink(destination: SelfSupportView()) {
//                    Text("GO TO SELF SUPPORT")
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.clear)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.black, lineWidth: 1)
//                        )
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Crisis Support")
//        .navigationBarTitleDisplayMode(.inline)
//        .background(Color("ZenGreen").ignoresSafeArea())
//    }
//}
//
//
//
//
////
////  ContactRow.swift
////  Zenframe
////
////  Created by Muhammad Ali Asgar Fataymamode on 18/04/2025.
////
//
//import SwiftUI
//
//struct ContactRow: View {
//    let title: String
//    let detail: String
//    let action: String
//    let color: Color
//
//    @State private var showCallPopup = false
//    @State private var showError = false
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(title)
//                .fontWeight(.semibold)
//            Text(detail)
//                .foregroundColor(.black.opacity(0.7))
//
//            HStack {
//                Spacer()
//                Button(action: {
//                    if title.contains("Teen Line") {
//                        showError = true
//                    } else {
//                        showCallPopup = true
//                    }
//                }) {
//                    Text(action)
//                        .font(.caption)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(color)
//                        .cornerRadius(20)
//                }
//            }
//        }
//        .padding()
//        .background(Color.white.opacity(0.3))
//        .cornerRadius(15)
//        .sheet(isPresented: $showCallPopup) {
//            CallPopupView(title: title)
//        }
//        .alert("Call Failed", isPresented: $showError) {
//            Button("Go to Self Support", role: .cancel) {
//                // You could navigate or trigger something here
//            }
//        } message: {
//            Text("Unable to place the call. Try visiting the Self Support page for help.")
//        }
//    }
//}


import SwiftUI

struct CrisisSupportView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("CRISIS SUPPORT")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("You are not alone. Help is available!!")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(20)

                Text("List of Contacts")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ContactRow(title: "National Suicide Prevention Lifeline", detail: "998", action: "CALL NOW", color: .red)
                ContactRow(title: "Crisis Text Line", detail: "Text HOME to 741741", action: "TEXT NOW", color: .yellow)
                ContactRow(title: "The National Domestic Violence Hotline", detail: "1-800-799-SAFE (7233)", action: "CALL NOW", color: .red)
                ContactRow(title: "Teen Line (Support by Teens, for Teens)", detail: "1-800-852-833", action: "CALL NOW", color: .red)

                Spacer()

                NavigationLink(destination: SelfSupportView()) {
                    Text("GO TO SELF SUPPORT")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
            }
            .padding()
        }
        .navigationTitle("Crisis Support")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("ZenGreen").ignoresSafeArea())
    }
}

