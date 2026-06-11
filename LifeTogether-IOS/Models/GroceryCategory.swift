//
//  GroceryCategory.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//


import Foundation

struct GroceryCategory: Identifiable, Hashable {
    let emoji: String
    let name: String

    var id: String { name }

    static let uncategorized = GroceryCategory(
        emoji: "❓️",
        name: "Uncategorized"
    )
}