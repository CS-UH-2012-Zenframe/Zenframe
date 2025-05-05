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
