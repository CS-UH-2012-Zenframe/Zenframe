//
//  ArticleCard.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//
import SwiftUI

struct ArticleCard: View {
    let article: Article

    var badgeColor: Color {
        switch article.positivity {
        case 75...100: return Color.green
        case 50..<75: return Color.yellow
        case 0..<50: return Color.red
        default: return Color.gray
    }}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(article.positivity) %")
                    .font(.caption)
                    .padding(6)
                    .background(badgeColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Text(article.summary)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)

            NavigationLink(destination: ArticleDetailView(article: article)) {
                Text("Read More")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }

            Divider()
        }
        .padding(.vertical, 5)
    }
}
