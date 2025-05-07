//
//
//import SwiftUI
//
//struct ArticleCard: View {
//    let article: ArticleSummary
//    @StateObject private var viewModel: ArticleViewModel
//    
//    init(article: ArticleSummary) {
//        self.article = article
//        _viewModel = StateObject(wrappedValue: ArticleViewModel(article: Article(
//            title: article.headline,
//            summary: article.excerpt,
//            positivity: article.positivity
//        )))
//    }
//
//    var badgeColor: Color {
//        switch viewModel.positivity {
//        case 75...100: return Color.green
//        case 50..<75: return Color.yellow
//        case 0..<50: return Color.red
//        default: return Color.gray
//        }
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text(article.headline)
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//
//                Spacer()
//
//                Text("\(viewModel.positivity) %")
//                    .font(.caption)
//                    .padding(6)
//                    .background(badgeColor)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//
//            Text(article.excerpt)
//                .font(.caption)
//                .foregroundColor(.gray)
//                .lineLimit(2)
//                
//            // Reactions
//            HStack(spacing: 20) {
//                Button(action: { viewModel.addReaction(.sad) }) {
//                    Text(ReactionType.sad.emoji)
//                        .font(.title3)
//                }
//                
//                Button(action: { viewModel.addReaction(.neutral) }) {
//                    Text(ReactionType.neutral.emoji)
//                        .font(.title3)
//                }
//                
//                Button(action: { viewModel.addReaction(.happy) }) {
//                    Text(ReactionType.happy.emoji)
//                        .font(.title3)
//                }
//                
//                Spacer()
//                
//                NavigationLink(destination: ArticleDetailView(viewModel: viewModel)) {
//                    Text("Read More")
//                        .font(.caption)
//                        .foregroundColor(.blue)
//                }
//            }
//            .padding(.top, 4)
//
//            Divider()
//        }
//        .padding(.vertical, 5)
//    }
//}


import SwiftUI

struct ArticleCard: View {
    let article: ArticleSummary
    @State private var selectedReaction: ReactionType? = nil

    var badgeColor: Color {
        switch article.positivity {
        case 75...100: return Color.green
        case 50..<75: return Color.yellow
        case 0..<50: return Color.red
        default: return Color.gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(article.headline)
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

            Text(article.excerpt)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
                
            // Enhanced Reactions
            HStack(spacing: 20) {
                Button(action: { selectedReaction = .sad }) {
                    Text(ReactionType.sad.emoji)
                        .font(.title3)
                        .foregroundColor(selectedReaction == .sad ? .red : .gray)
                }
                
                Button(action: { selectedReaction = .neutral }) {
                    Text(ReactionType.neutral.emoji)
                        .font(.title3)
                        .foregroundColor(selectedReaction == .neutral ? .yellow : .gray)
                }
                
                Button(action: { selectedReaction = .happy }) {
                    Text(ReactionType.happy.emoji)
                        .font(.title3)
                        .foregroundColor(selectedReaction == .happy ? .green : .gray)
                }
                
                Spacer()
                
                NavigationLink(destination: ArticleDetailView(viewModel: ArticleViewModel(article: Article(
                    title: article.headline,
                    summary: article.excerpt,
                    positivity: article.positivity
                )))) {
                    Text("Read More")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 4)

            Divider()
        }
        .padding(.vertical, 5)
    }
}
