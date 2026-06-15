//
//  GrocerySuggestion.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 15/06/2026.
//

import Foundation

struct GrocerySuggestion: Identifiable, Equatable, Sendable {
    let id: String
    var suggestionName: String
    var category: GroceryCategory
    var approxPrice: Float?
    var lastUpdated: Date

    init(
        id: String = UUID().uuidString,
        suggestionName: String,
        category: GroceryCategory,
        approxPrice: Float? = nil,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.suggestionName = suggestionName
        self.category = category
        self.approxPrice = approxPrice
        self.lastUpdated = lastUpdated
    }
}
