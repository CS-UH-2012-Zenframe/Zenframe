import SwiftUI

struct ArticleDetailView: View {
    @ObservedObject var viewModel: ArticleViewModel
    @State private var commentText: String = ""
    @State private var comments: [String] = [
        "John Doe: This gives me hope! We need to continue investing in renewable energy sources.",
        "Michael Johnson: Great article, I will be sharing this with my students at school!"
    ]
    @State private var errorMessage: String? = nil

    let prohibitedWords = ["stupid", "idiot", "hate"]

    var badgeColor: Color {
        switch viewModel.positivity {
        case 75...100: return .green
        case 50..<75: return .yellow
        case 0..<50: return .red
        default: return .gray
        }
    }

    var badgeEmoji: String {
        switch viewModel.positivity {
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
                    Text(viewModel.title)
                        .font(.title3)
                        .bold()

                    HStack {
                        Text("\(viewModel.positivity) % \(badgeEmoji)")
                            .font(.caption)
                            .padding(6)
                            .background(badgeColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)

                        Spacer()
                    }

                    Text(viewModel.summary)
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

                    // Reactions
                    HStack(spacing: 40) {
                        Button(action: { viewModel.addReaction(.sad) }) {
                            Text(ReactionType.sad.emoji)
                                .font(.largeTitle)
                        }
                        Button(action: { viewModel.addReaction(.neutral) }) {
                            Text(ReactionType.neutral.emoji)
                                .font(.largeTitle)
                        }
                        Button(action: { viewModel.addReaction(.happy) }) {
                            Text(ReactionType.happy.emoji)
                                .font(.largeTitle)
                        }
                    }
                    .padding(.top, 10)
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
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                    }

                    Button("Post Comment") {
                        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)

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

// Preview
#Preview {
    NavigationStack {
        ArticleDetailView(viewModel: ArticleViewModel(article: Article(
            title: "Renewable Energy Advances Offer Hope",
            summary: "Recent breakthroughs in wind and solar technologies are providing promising solutions.",
            positivity: 92
        )))
    }
}
