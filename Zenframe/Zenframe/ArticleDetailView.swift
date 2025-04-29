//
//  ArticleDetailView.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//


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
    
    @EnvironmentObject var sessionStore: SessionStore
    
    let prohibitedWords = ["stupid", "idiot", "hate"]

    var badgeColor: Color {
        guard let article = article else { return .gray }
        switch article.positivity {
        case 75...100: return Color.green
        case 50..<75: return Color.yellow
        case 0..<50: return Color.red
        default: return Color.gray
        }
    }

    var badgeEmoji: String {
        guard let article = article else { return "" }
        switch article.positivity {
        case 75...100: return "😊"
        case 50..<75: return "😐"
        case 0..<50: return "😟"
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
            Task {
                await fetchArticleDetail()
            }
        }
        .sheet(isPresented: $showingSafari) {
            if let article = article, let url = URL(string: article.source_url) {
                SafariView(url: url)
            }
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
                            .foregroundColor(.white)
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
                        .foregroundColor(.black.opacity(0.8))
                        .padding(.bottom, 8)
                    
                    Text(article.full_body)
                        .font(.body)
                        .foregroundColor(.black.opacity(0.8))

                    Button("READ FULL STORY") {
                        showingSafari = true
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

                ForEach(article.comments.reversed()) { comment in
                    VStack(alignment: .leading) {
                        if let date = formatDate(comment.created_date.date) {
                            Text(date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(comment.comment_content)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(20)
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
                    .background(isValidComment ? Color.blue : Color.blue.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(20)
            }
            .padding()
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
