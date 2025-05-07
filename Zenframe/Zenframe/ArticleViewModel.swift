//
//  ArticleViewModel.swift
//  Zenframe
//
//  Created by Absera on 7/5/25.
//


// ArticleViewModel.swift
// New view model to manage dynamic state and reactions
import Foundation
import SwiftUI

enum ReactionType {
    case sad, neutral, happy

    var value: Int {
        switch self {
        case .happy: return 100
        case .neutral: return 50
        case .sad: return 0
        }
    }

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .neutral: return "😐"
        case .sad: return "😟"
        }
    }
}

class ArticleViewModel: ObservableObject, Identifiable {
    let id = UUID()
    let title: String
    let summary: String

    @Published private(set) var positivity: Int
    private var totalScore: Int
    private var reactionCount: Int

    init(article: Article) {
        self.title = article.title
        self.summary = article.summary
        self.positivity = article.positivity
        self.totalScore = article.positivity
        self.reactionCount = 1
    }

    func addReaction(_ type: ReactionType) {
        totalScore += type.value
        reactionCount += 1
        positivity = totalScore / reactionCount
    }
}
