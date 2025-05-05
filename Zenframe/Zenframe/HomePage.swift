//
//  HomePage.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.


import SwiftUI
import SafariServices

struct HomePage: View {
    @State private var filterValue: Int = 0
    @State private var showPositivityFilter = false
    @State private var showInterestFilter = false
    @State private var selectedCategory: String? = nil
    @State private var articles: [ArticleSummary] = []
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var errorMessage: String? = nil
    @State private var offset = 0
    @State private var hasMoreArticles = true
    @State private var showingProfileSheet = false
    @State private var positiveOnly = false        // NEW
    
    @EnvironmentObject var sessionStore: SessionStore
    
    // Mapping UI categories to backend categories
    private let categoryMapping: [String: String] = [
        "World": "world",
        "Politics": "politics",
        "Business": "business",
        "Technology": "tech",
        "Science": "science",
        "Health": "health",
        "Sports": "sports",
        "Entertainment": "entertainment",
        "Travel": "travel",
        "Lifestyle": "lifestyle",
        "Other": "other"
    ]
    
    @State private var interests: [String: Bool] = [
        "World": false,
        "Politics": false,
        "Technology": false,
        "Science": false,
        "Health": false,
        "Sports": false,
        "Entertainment": false,
        "Travel": false,
        "Lifestyle": false,
        "Business": false,
        "Other": false
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Zenframe")
                    .font(.title)
                    .bold()

                Text("Stay informed, stay calm.")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
                
                
                // Positive‑only toggle
                Button(action: {
                    positiveOnly.toggle()
                    // reset other filters & reload
                    filterValue = 0
                    selectedCategory = nil
                    Task { await loadArticles(refresh: true) }
                }) {
                    HStack {
                        Image(systemName: positiveOnly ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(positiveOnly ? .mint : .secondary)
                        Text("Positive News Only")
                            .fontWeight(positiveOnly ? .bold : .regular)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                }
                .padding(.bottom, 4)
                // MARK: Filter By Positivity
                Button(action: {
                    showPositivityFilter.toggle()
                    showInterestFilter = false
                }) {
                    HStack {
                        Text("Filter By Positivity")
                        Spacer()
                        Image(systemName: showPositivityFilter ? "chevron.up" : "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                }

                if showPositivityFilter {
                    VStack(alignment: .leading, spacing: 10) {
                        Slider(value: Binding(
                            get: { Double(filterValue) },
                            set: { filterValue = Int($0) }
                        ), in: 0...100, step: 1)

                        Text("Current Filter: \(filterValue)%")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Button("Apply") {
                            showPositivityFilter = false
                            Task {
                                await loadArticles(refresh: true)
                            }
                        }
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .padding(.bottom, 10)
                }

                // MARK: Filter By Interest
                Button(action: {
                    showInterestFilter.toggle()
                    showPositivityFilter = false
                }) {
                    HStack {
                        Text("Filter By Category")
                        Spacer()
                        Image(systemName: showInterestFilter ? "chevron.up" : "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                }

                if showInterestFilter {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(interests.keys.sorted(), id: \.self) { key in
                            Button(action: {
                                for k in interests.keys {
                                    interests[k] = false
                                }
                                interests[key] = true
                                selectedCategory = categoryMapping[key]
                                showInterestFilter = false
                                Task {
                                    await loadArticles(refresh: true)
                                }
                            }) {
                                HStack {
                                    Text(key)
                                    Spacer()
                                    if interests[key] == true {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        Button("Clear Filter") {
                            for k in interests.keys {
                                interests[k] = false
                            }
                            selectedCategory = nil
                            showInterestFilter = false
                            Task {
                                await loadArticles(refresh: true)
                            }
                        }
                        .padding(6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 10)
                }

                // News Section Header
                HStack {
                    Text("News")
                        .font(.headline)
                    
                    Spacer()
                    
                    if isLoading && !isLoadingMore {
                        ProgressView()
                    }
                }
                .padding(.top, 8)

                // Article Count
                Text("\(articles.count) articles")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }

                // Article List
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(articles) { article in
                            NavigationLink(destination: ArticleDetailView(newsId: article.news_id)) {
                                ArticleCardView(article: article)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if !articles.isEmpty && hasMoreArticles {
                            Button(action: {
                                Task {
                                    await loadMoreArticles()
                                }
                            }) {
                                if isLoadingMore {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .padding()
                                } else {
                                    Text("Load More")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .disabled(isLoadingMore)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.4), lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding()
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingProfileSheet = true
                    }) {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                    }
                }
            }
            .onAppear {
                Task {
                    await loadArticles(refresh: true)
                }
            }
            .sheet(isPresented: $showingProfileSheet) {
                ProfilePage()
                    .environmentObject(sessionStore)
            }
        }
    }
    
    private func loadArticles(refresh: Bool = false) async {
        if refresh {
            isLoading = true
            offset = 0
            hasMoreArticles = true
        } else {
            isLoadingMore = true
        }
        
        errorMessage = nil
        
        do {
            let newArticles = try await APIService.shared.getNews(
                positivity: positiveOnly ? 66 : (filterValue > 0 ? filterValue : nil),
                category:   selectedCategory,
                limit:      10,
                offset:     offset
            )
            
//            let newArticles = try await APIService.shared.getNews(
//                positivity: filterValue > 0 ? filterValue : nil,
//                category: selectedCategory,
//                limit: 10,
//                offset: offset
//            )
            
            if refresh {
                articles = newArticles
            } else {
                articles.append(contentsOf: newArticles)
            }
            
            // Update offset for pagination
            offset += newArticles.count
            hasMoreArticles = newArticles.count == 10
            
        } catch let error as APIService.APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load articles: \(error.localizedDescription)"
        }
        
        isLoading = false
        isLoadingMore = false
    }
    
    private func loadMoreArticles() async {
        await loadArticles(refresh: false)
    }
}

struct ArticleCardView: View {
    let article: ArticleSummary
    
    var badgeColor: Color {
        switch article.positivity {
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
        switch article.positivity {
        case 66...100: return "👍"
        case 35..<66: return "😐"
        case 0..<35: return "👎"
        default: return ""
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.headline)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            HStack {
                Text("\(article.positivity)% \(badgeEmoji)")
                    .font(.caption)
                    .padding(4)
                    .background(badgeColor)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                
                Text(article.category.capitalized)
                    .font(.caption)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Spacer()
                
                // Format date
                if let date = formatDate(article.created_date.date) {
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(article.excerpt)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func formatDate(_ dateString: String) -> String? {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            return outputFormatter.string(from: date)
        }
        return nil
    }
}
