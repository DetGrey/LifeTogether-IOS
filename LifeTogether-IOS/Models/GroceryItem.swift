//
//  GroceryItem.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//
import Foundation

struct GroceryItem: Identifiable, Equatable {
    let id: String
    let familyId: String
    var itemName: String
    var category: GroceryCategory
    var completed: Bool
    var approxPrice: Float?
    var lastUpdated: Date

    init(
        id: String = UUID().uuidString,
        familyId: String,
        itemName: String,
        category: GroceryCategory,
        completed: Bool = false,
        approxPrice: Float? = nil,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.familyId = familyId
        self.itemName = itemName
        self.category = category
        self.completed = completed
        self.approxPrice = approxPrice
        self.lastUpdated = lastUpdated
    }
}
