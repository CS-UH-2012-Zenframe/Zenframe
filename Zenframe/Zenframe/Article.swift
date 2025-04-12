//
//  Article.swift
//  Zenframe
//
//  Created by Muhammad Ali Asgar Fataymamode on 11/04/2025.
//

import Foundation

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let positivity: Int
}
