//
//  HomePage.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//
//
//
//import SwiftUI
//
//struct Article: Identifiable {
//    let id = UUID()
//    let title: String
//    let summary: String
//    let positivity: Int
//}
//
//struct HomePage: View {
//    @State private var filterValue: Int = 0
//    @State private var showFilter: Bool = false
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
//                // Filter dropdown
//                Button(action: {
//                    showFilter.toggle()
//                }) {
//                    HStack {
//                        Text("Filter By Positivity")
//                        Spacer()
//                        Image(systemName: showFilter ? "chevron.up" : "chevron.down")
//                    }
//                    .padding()
//                    .background(Color(.systemGray5))
//                    .cornerRadius(10)
//                }
//
//                if showFilter {
//                    Slider(value: Binding(
//                        get: { Double(filterValue) },
//                        set: { filterValue = Int($0) }
//                    ), in: 0...100, step: 1)
//                    Text("Current Filter: \(filterValue)%")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .padding(.bottom, 10)
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
//                            // Placeholder for future pagination
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
//
//struct ArticleCard: View {
//    let article: Article
//
//    var badgeColor: Color {
//        switch article.positivity {
//        case 75...100: return Color.green
//        case 50..<75: return Color.yellow
//        case 0..<50: return Color.red
//        default: return Color.gray
//    }}
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text(article.title)
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//
//                Spacer()
//
//                Text("\(article.positivity) %")
//                    .font(.caption)
//                    .padding(6)
//                    .background(badgeColor)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//
//            Text(article.summary)
//                .font(.caption)
//                .foregroundColor(.gray)
//                .lineLimit(2)
//
//            NavigationLink(destination: Text("Full Article Page")) {
//                Text("Read More")
//                    .font(.caption)
//                    .foregroundColor(.blue)
//                    .padding(.top, 4)
//            }
//
//            Divider()
//        }
//        .padding(.vertical, 5)
//    }
//}
//
//#Preview {
//    HomePage()
//}

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

                Text("News")
                    .font(.headline)
                    .padding(.top)

                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(articles.filter { $0.positivity >= filterValue }) { article in
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
