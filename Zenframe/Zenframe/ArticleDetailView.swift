//
//  ArticleDetailView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//


import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @State private var commentText: String = ""
    @State private var comments: [String] = [
        "John Doe: This gives me hope! We need to continue investing in renewable energy sources.",
        "Michael Johnson: Great article, I will be sharing this with my students at school!"
    ]
    @State private var errorMessage: String? = nil

    let prohibitedWords = ["stupid", "idiot", "hate"]

    var badgeColor: Color {
        switch article.positivity {
        case 75...100: return Color.green
        case 50..<75: return Color.yellow
        case 0..<50: return Color.red
        default: return Color.gray
        }
    }

    var badgeEmoji: String {
        switch article.positivity {
        case 75...100: return "😊"
        case 50..<75: return "😐"
        case 0..<50: return "😟"
        default: return ""
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Article Box
                VStack(alignment: .leading, spacing: 10) {
                    Text(article.title)
                        .font(.title3)
                        .bold()

                    HStack {
                        Text("\(article.positivity) % \(badgeEmoji)")
                            .font(.caption)
                            .padding(6)
                            .background(badgeColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)

                        Spacer()
                    }

                    Text("Recent breakthroughs in wind and solar technologies are providing promising solutions to address climate change, according to a new report released ....")
                        .font(.body)
                        .foregroundColor(.black.opacity(0.8))

                    Button("READ MORE") {
                        // Future link
                    }
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(20)

                // Comments Section
                Text("Comments")
                    .font(.headline)

                ForEach(comments, id: \.self) { comment in
                    let components = comment.split(separator: ":", maxSplits: 1).map { String($0) }
                    VStack(alignment: .leading) {
                        if components.count == 2 {
                            Text("\(Text(components[0]).bold()): \(components[1].trimmingCharacters(in: .whitespaces))")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(20)
                        } else {
                            Text(comment)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(20)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Add your comment:")
                        .fontWeight(.semibold)

                    TextField("Type your thoughts here ...", text: $commentText)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
//                            .font(.caption)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                    }

                    Button("Post Comment") {
                        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)

                        // Validation
                        if trimmed.isEmpty {
                            errorMessage = "Comment cannot be empty!"
                        } else if trimmed.count > 200 {
                            errorMessage = "Comment must be under 200 characters!"
                        } else if containsProhibitedWord(trimmed) {
                            errorMessage = "Comment contains prohibited language!"
                        } else {
                            comments.append("You: \(trimmed)")
                            commentText = ""
                            errorMessage = nil
                        }
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(20)
            }
            .padding()
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.gray.opacity(0.2).ignoresSafeArea())
    }

    private func containsProhibitedWord(_ text: String) -> Bool {
        for word in prohibitedWords {
            if text.lowercased().contains(word.lowercased()) {
                return true
            }
        }
        return false
    }
}

#Preview {
    NavigationStack {
        ArticleDetailView(article: Article(
            title: "Renewable Energy Advances Offer Hope",
            summary: "Recent breakthroughs in wind and solar technologies are providing promising solutions.",
            positivity: 92)
        )
    }
}


//import SwiftUI
//
//struct ArticleDetailView: View {
//    let article: Article
//    @State private var commentText: String = ""
//    @State private var comments: [String] = [
//        "John Doe: This gives me hope! We need to continue investing in renewable energy sources.",
//        "Michael Johnson: Great article, I will be sharing this with my students at school!"
//    ]
//
//    var badgeColor: Color {
//        switch article.positivity {
//        case 75...100: return Color.green
//        case 50..<75: return Color.yellow
//        case 0..<50: return Color.red
//        default: return Color.gray
//        }
//    }
//
//    var badgeEmoji: String {
//        switch article.positivity {
//        case 75...100: return "😊"
//        case 50..<75: return "😐"
//        case 0..<50: return "😟"
//        default: return ""
//        }
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // Article Section
//                VStack(alignment: .leading, spacing: 10) {
//                    Text(article.title)
//                        .font(.title3)
//                        .bold()
//
//                    HStack {
//                        Text("\(article.positivity) % \(badgeEmoji)")
//                            .font(.caption)
//                            .padding(6)
//                            .background(badgeColor)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//
//                        Spacer()
//                    }
//
//                    Text("Recent breakthroughs in wind and solar technologies are providing promising solutions to address climate change, according to a new report released ....")
//                        .font(.body)
//                        .foregroundColor(.black.opacity(0.8))
//
//                    Button("READ MORE") {
//                        // You can link to external article or expand text
//                    }
//                    .padding(.vertical, 6)
//                    .frame(maxWidth: .infinity)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.black, lineWidth: 1)
//                    )
//                }
//                .padding()
//                .background(Color.white.opacity(0.3))
//                .cornerRadius(20)
//
//                // Comments Section
//                Text("Comments")
//                    .font(.headline)
//
//                ForEach(comments, id: \.self) { comment in
//                    Text(comment)
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color.white.opacity(0.3))
//                        .cornerRadius(20)
//                }
//
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Add your comment:")
//                        .fontWeight(.semibold)
//
//                    TextField("Type your thoughts here ...", text: $commentText)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(25)
//
//                    Button("Post Comment") {
//                        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
//                        if !trimmed.isEmpty {
//                            comments.append("You: \(trimmed)")
//                            commentText = ""
//                        }
//                    }
//                    .padding(.top, 4)
//                }
//                .padding()
//                .background(Color.white.opacity(0.3))
//                .cornerRadius(20)
//            }
//            .padding()
//        }
//        .navigationTitle("Article")
//        .navigationBarTitleDisplayMode(.inline)
//        .background(Color.gray.opacity(0.2).ignoresSafeArea()) // replace with Color("ZenGreen") if needed
//    }
//}
//
//#Preview {
//    NavigationStack {
//        ArticleDetailView(article: Article(
//            title: "Renewable Energy Advances Offer Hope",
//            summary: "Recent breakthroughs in wind and solar technologies are providing promising solutions.",
//            positivity: 92)
//        )
//    }
//}
