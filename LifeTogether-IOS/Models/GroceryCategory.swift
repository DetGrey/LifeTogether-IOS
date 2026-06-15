//
//  GroceryCategory.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//


import Foundation

struct GroceryCategory: Identifiable, Hashable, Sendable {
    let emoji: String
    let name: String
    let lastUpdated: Date

    var id: String { name }

    static let uncategorized = GroceryCategory(
        emoji: "❓️",
        name: "Uncategorized",
        lastUpdated: Date()
    )

    init(
        emoji: String,
        name: String,
        lastUpdated: Date = Date()
    ) {
        self.emoji = emoji
        self.name = name
        self.lastUpdated = lastUpdated
    }
}
