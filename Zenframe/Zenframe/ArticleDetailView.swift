
import SwiftUI
import SafariServices

struct ArticleDetailView: View {
    let newsId: String
    
    @State private var article: ArticleDetail?
    @State private var commentText: String = ""
    @State private var isLoading = true
    @State private var isSubmittingComment = false
    @State private var errorMessage: String? = nil
    @State private var showingSafari = false
    
    // Simplified reaction state - just track which one is selected
    @State private var selectedReaction: ReactionType? = nil
    @AppStorage("reaction_") private var savedReaction: String = ""
    
    @State private var reactionCounts: [ReactionType: Int] = [.happy: 0, .neutral: 0, .sad: 0]
    private var happinessRating: Int {
        let h = Double(reactionCounts[.happy] ?? 0)
        let n = Double(reactionCounts[.neutral] ?? 0)
        let s = Double(reactionCounts[.sad] ?? 0)
        let total = h + n + s

        guard total > 0 else { return 0 }

        let score = (h * 1.0 + n * 0.5 + s * 0.0) / total
        return Int(round(score * 100))  // out of 100
    }
    
    @EnvironmentObject var sessionStore: SessionStore
    
    let prohibitedWords = ["stupid", "idiot", "hate"]
    
    // Enum for reaction types
    enum ReactionType: Int, CaseIterable {
        case happy = 1     // 😀
        case neutral = 2   // 😐
        case sad = 3       // 😢

        var emoji: String {
            switch self {
            case .happy:   return "😁"
            case .neutral: return "😐"
            case .sad:     return "🥺"
            }
        }
    }

    var badgeColor: Color {
        guard let score = article?.positivity else { return .gray }

        switch score {
        case 66...100:      // high positivity
            return Color.mint                  // fresh green‑teal
        case 35..<66:       // mixed / neutral
            return Color.orange.opacity(0.85)  // modern amber
        case 0..<35:        // low positivity
            return Color.pink                  // soft caution
        default:
            return .gray                       // fallback
        }
    }

    var badgeEmoji: String {
        guard let article = article else { return "" }
        switch article.positivity {
        case 66...100: return "👍"
        case 36..<65: return "😐"
        case 0..<35: return "👎"
        default: return ""
        }
    }

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading article...")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            } else if let article = article {
                articleDetailContent(article)
            } else {
                Text("Failed to load article")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.gray.opacity(0.2).ignoresSafeArea())
        .onAppear {
            // Load the saved reaction when the view appears
            loadSavedReaction()
            
            Task {
                await fetchArticleDetail()
            }
            
            Task { await fetchReactionCounts() }

        }
        .sheet(isPresented: $showingSafari) {
            if let article = article, let url = URL(string: article.source_url) {
                SafariView(url: url)
            }
        }
    }
    
    private func fetchReactionCounts() async {
        await withTaskGroup(of: (ReactionType, Int).self) { group in
            for kind in ReactionType.allCases {
                group.addTask {
                    let c = try? await APIService.shared.getReactionCount(newsId: newsId,
                                                                         reactionType: kind.rawValue)
                    return (kind, c ?? 0)
                }
            }
            var fresh = reactionCounts
            for await (kind, c) in group { fresh[kind] = c }
            reactionCounts = fresh
        }
    }
    
    private func loadSavedReaction() {
        let reactionKey = "reaction_\(newsId)"

        let storedValue = UserDefaults.standard.integer(forKey: reactionKey) // 0 if missing
        if let reaction = ReactionType(rawValue: storedValue) {
            selectedReaction = reaction
        }
    }
    
    private func saveReaction(type: ReactionType?) {
        // Use the article ID as part of the key to make it unique per article
        let reactionKey = "reaction_\(newsId)"
        
        if let type = type {
            // Save the reaction type as a string
            UserDefaults.standard.set(type.rawValue, forKey: reactionKey)
        } else {
            // If nil, remove any saved reaction
            UserDefaults.standard.removeObject(forKey: reactionKey)
        }
    }
    
    private func articleDetailContent(_ article: ArticleDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Article Box
                VStack(alignment: .leading, spacing: 10) {
                    Text(article.headline)
                        .font(.title3)
                        .bold()

                    HStack {
                        Text("\(article.positivity) % \(badgeEmoji)")
                            .font(.caption)
                            .padding(6)
                            .background(badgeColor)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                        
                        Text(article.category.capitalized)
                            .font(.caption)
                            .padding(6)
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(10)

                        Spacer()
                    }

                    Text(article.excerpt)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 8)
                    
                    Text(article.full_body)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))

                    Button("READ FULL STORY") {
                        showingSafari = true
                    }
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    
                    // Updated simplified reaction section without counts
                    HStack(spacing: 20) {
                        reactionButton(type: .happy, isSelected: selectedReaction == .happy)
                        reactionButton(type: .neutral, isSelected: selectedReaction == .neutral)
                        reactionButton(type: .sad, isSelected: selectedReaction == .sad)
                    }
                    .padding(.top, 10)
                    
                    Text("Happiness rating: \(happinessRating)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .cornerRadius(20)

                // Comments Section
                Text("Comments")
                    .font(.headline)

                ForEach(article.comments.reversed()) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 6) {
                            Text("Anonymous")                 // leave comments as anonymous to protect identity
                                .font(.subheadline)

                            Text(comment.comment_content)
                                .padding(8)
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if let date = formatDate(comment.created_date.date) {
                            Text(date)
                                .font(.caption)
                                .foregroundColor(.secondary)
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
                        .foregroundColor(Color.black)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                    }

                    Button(action: {
                        Task {
                            await submitComment()
                        }
                    }) {
                        if isSubmittingComment {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Post Comment")
                        }
                    }
                    .disabled(isSubmittingComment || !isValidComment)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isValidComment ? Color.green : Color.green.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .cornerRadius(20)
            }
            .padding()
        }
    }
    
    // Simplified reaction button without count
    private func reactionButton(type: ReactionType, isSelected: Bool) -> some View {
        VStack(spacing: 4) {
            Button { Task { await handleReaction(type: type) } } label: {
                Text(type.emoji)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? Color.white.opacity(0.3) : Color.clear)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
            Text("\(reactionCounts[type] ?? 0)")
                .font(.caption2)
        }
    }

    
    // Simplified reaction handling
    private func handleReaction(type: ReactionType) async {
        selectedReaction = type
        saveReaction(type: type)          // keep local persistence if you want

        do {
            try await APIService.shared.addReaction(newsId: newsId,
                                                    reactionType: type.rawValue)
            await fetchReactionCounts()   // pull fresh numbers
        } catch {
            print("❌ Failed to record reaction:", error)
        }
    }
    
    private var isValidComment: Bool {
        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 200 && !containsProhibitedWord(trimmed)
    }

    private func fetchArticleDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            article = try await APIService.shared.getArticleDetail(newsId: newsId)
        } catch let error as APIService.APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load article: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func submitComment() async {
        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation
        if trimmed.isEmpty {
            errorMessage = "Comment cannot be empty!"
            return
        } else if trimmed.count > 200 {
            errorMessage = "Comment must be under 200 characters!"
            return
        } else if containsProhibitedWord(trimmed) {
            errorMessage = "Comment contains prohibited language!"
            return
        }
        
        isSubmittingComment = true
        errorMessage = nil
        
        do {
            let newComment = try await APIService.shared.addComment(newsId: newsId, comment: trimmed)
            
            // Update the UI optimistically
            if var updatedArticle = article {
                updatedArticle.comments.append(newComment)
                article = updatedArticle
            }
            
            commentText = ""
        } catch let error as APIService.APIError {
            errorMessage = "Comment Added!"
            commentText = ""
            await fetchArticleDetail()
            commentText = ""
        } catch {
            errorMessage = "Failed to post comment: \(error.localizedDescription)"
        }
        
        isSubmittingComment = false
    }

    private func containsProhibitedWord(_ text: String) -> Bool {
        for word in prohibitedWords {
            if text.lowercased().contains(word.lowercased()) {
                return true
            }
        }
        return false
    }
    
    private func formatDate(_ dateString: String) -> String? {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            outputFormatter.timeStyle = .short
            return outputFormatter.string(from: date)
        }
        return nil
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // Nothing to do
    }
}

#Preview {
    NavigationStack {
        ArticleDetailView(newsId: "sample_id")
            .environmentObject(SessionStore())
    }
}
