//
//  HomePage.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.


import SwiftUI

struct HomePage: View {
    
    @State private var filterValue: Int = 0
    @State private var showPositivityFilter = false
    @State private var showInterestFilter = false

    @State private var interests: [String: Bool] = [
        "Environment": false,
        "Technology": false,
        "Politics": false,
        "Economy": false,
        "Health": false,
        "Education": false
    ]

    let articles = [
        Article(title: "Renewable Energy Advances Offer Hope",
                summary: "Renewable energy gains momentum even in the face of climate uncertainty.",
                positivity: 92),
        Article(title: "Community Gardens Flourish in Cities",
                summary: "Green spaces are growing in urban zones, helping the environment and residents.",
                positivity: 83),
        Article(title: "Global Economic Forum ends with mixed views",
                summary: "Forecasts show both optimism and concern for future market trends.",
                positivity: 50),
        Article(title: "Housing prices rise despite government efforts",
                summary: "Real estate costs continue to climb as regulation struggles to catch up.",
                positivity: 30)
    ]
    
    // 🆕 Computed filtered articles
    var filteredArticles: [Article] {
        articles.filter { $0.positivity >= filterValue }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Zenframe")
                    .font(.title)
                    .bold()

                Text("Stay informed, stay calm.")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))

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

                        Button("Done") {
                            showPositivityFilter = false
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
                        Text("Filter By Interest")
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
                            Toggle(isOn: Binding(
                                get: { interests[key] ?? false },
                                set: { interests[key] = $0 }
                            )) {
                                Text(key)
                            }
                        }

                        Button("Done") {
                            showInterestFilter = false
                        }
                        .padding(6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 10)
                }

                // 🔁 News Section Header
                Text("News")
                    .font(.headline)
                    .padding(.top, 8)

                // 🆕 Article Count
                Text("\(filteredArticles.count) articles")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // 🔁 Article List
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(filteredArticles) { article in
                            ArticleCard(article: article)
                        }

                        Button("Load More") {
                            // Pagination placeholder
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
                        )
                    }
                }

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}



//import SwiftUI
//
//
//struct HomePage: View {
//    
//    @State private var filterValue: Int = 0
//    @State private var showPositivityFilter = false
//    @State private var showInterestFilter = false
//
//    @State private var interests: [String: Bool] = [
//        "Environment": false,
//        "Technology": false,
//        "Politics": false,
//        "Economy": false,
//        "Health": false,
//        "Education": false
//    ]
//
//    let articles = [
//        Article(title: "Renewable Energy Advances Offer Hope",
//                summary: "Renewable energy gains momentum even in the face of climate uncertainty.",
//                positivity: 92),
//        Article(title: "Community Gardens Flourish in Cities",
//                summary: "Green spaces are growing in urban zones, helping the environment and residents.",
//                positivity: 83),
//        Article(title: "Global Economic Forum ends with mixed views",
//                summary: "Forecasts show both optimism and concern for future market trends.",
//                positivity: 50),
//        Article(title: "Housing prices rise despite government efforts",
//                summary: "Real estate costs continue to climb as regulation struggles to catch up.",
//                positivity: 30)
//    ]
//
//    var body: some View {
//        NavigationView {
//            VStack(alignment: .leading, spacing: 10) {
//                Text("Zenframe")
//                    .font(.title)
//                    .bold()
//
//                Text("Stay informed, stay calm.")
//                    .font(.subheadline)
//                    .foregroundColor(.black.opacity(0.6))
//
//                // MARK: Filter By Positivity
//                Button(action: {
//                    showPositivityFilter.toggle()
//                    showInterestFilter = false
//                }) {
//                    HStack {
//                        Text("Filter By Positivity")
//                        Spacer()
//                        Image(systemName: showPositivityFilter ? "chevron.up" : "chevron.down")
//                    }
//                    .padding()
//                    .background(Color(.systemGray5))
//                    .cornerRadius(10)
//                }
//
//                if showPositivityFilter {
//                    VStack(alignment: .leading, spacing: 10) {
//                        Slider(value: Binding(
//                            get: { Double(filterValue) },
//                            set: { filterValue = Int($0) }
//                        ), in: 0...100, step: 1)
//
//                        Text("Current Filter: \(filterValue)%")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//
//                        Button("Done") {
//                            showPositivityFilter = false
//                        }
//                        .padding(6)
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(6)
//                    }
//                    .padding(.bottom, 10)
//                }
//
//                // MARK: Filter By Interest
//                Button(action: {
//                    showInterestFilter.toggle()
//                    showPositivityFilter = false
//                }) {
//                    HStack {
//                        Text("Filter By Interest")
//                        Spacer()
//                        Image(systemName: showInterestFilter ? "chevron.up" : "chevron.down")
//                    }
//                    .padding()
//                    .background(Color(.systemGray5))
//                    .cornerRadius(10)
//                }
//
//                if showInterestFilter {
//                    VStack(alignment: .leading, spacing: 8) {
//                        ForEach(interests.keys.sorted(), id: \.self) { key in
//                            Toggle(isOn: Binding(
//                                get: { interests[key] ?? false },
//                                set: { interests[key] = $0 }
//                            )) {
//                                Text(key)
//                            }
//                        }
//
//                        Button("Done") {
//                            showInterestFilter = false
//                        }
//                        .padding(6)
//                        .background(Color.green.opacity(0.1))
//                        .cornerRadius(6)
//                        .padding(.top, 8)
//                    }
//                    .padding(.bottom, 10)
//                }
//
//                Text("News")
//                    .font(.headline)
//                    .padding(.top)
//
//                ScrollView {
//                    VStack(spacing: 15) {
//                        ForEach(articles.filter { $0.positivity >= filterValue }) { article in
//                            ArticleCard(article: article)
//                        }
//
//                        Button("Load More") {
//                            // Pagination placeholder
//                        }
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.clear)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.black.opacity(0.4), lineWidth: 1)
//                        )
//                    }
//                }
//
//                Spacer()
//            }
//            .padding()
//            .navigationBarHidden(true)
//        }
//    }
//}
