//
//  GroceryListViewModel.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import Foundation
import Observation

@Observable
final class GroceryListViewModel {
    var items: [GroceryItem]
    var newItemName = ""
    var newItemPrice = ""
    var selectedCategory: GroceryCategory = .uncategorized
    var expandedCategories: Set<String>
    var isCompletedSectionExpanded = false

    let groceryCategories: [GroceryCategory] = [
        .uncategorized,
        GroceryCategory(emoji: "🥦", name: "Vegetables"),
        GroceryCategory(emoji: "🍎", name: "Fruits"),
        GroceryCategory(emoji: "🥛", name: "Dairy"),
        GroceryCategory(emoji: "🍞", name: "Bread"),
        GroceryCategory(emoji: "🧼", name: "Household")
    ]

    init() {
        self.items = [
            GroceryItem(itemName: "Bananas", category: GroceryCategory(emoji: "🍎", name: "Fruits"), approxPrice: 12),
            GroceryItem(itemName: "Milk", category: GroceryCategory(emoji: "🥛", name: "Dairy"), approxPrice: 15),
            GroceryItem(itemName: "Dish soap", category: GroceryCategory(emoji: "🧼", name: "Household")),
            GroceryItem(itemName: "Potatoes", category: GroceryCategory(emoji: "🥦", name: "Vegetables"), completed: true)
        ]

        self.expandedCategories = Set(groceryCategories.map(\.name))
    }

    var canAddItem: Bool {
        !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var completedItems: [GroceryItem] {
        items
            .filter(\.completed)
            .sorted { $0.lastUpdated > $1.lastUpdated }
    }

    var activeItemsByCategory: [(category: GroceryCategory, items: [GroceryItem])] {
        groceryCategories.compactMap { category in
            let categoryItems = items
                .filter { !$0.completed && $0.category.name == category.name }
                .sorted { $0.itemName.localizedCaseInsensitiveCompare($1.itemName) == .orderedAscending }

            return categoryItems.isEmpty ? nil : (category, categoryItems)
        }
    }

    var expectedTotalPrice: Float? {
        let prices = items
            .filter { !$0.completed }
            .compactMap(\.approxPrice)

        return prices.isEmpty ? nil : prices.reduce(0, +)
    }

    func addItem() {
        guard canAddItem else { return }

        let item = GroceryItem(
            itemName: newItemName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            approxPrice: Float(newItemPrice)
        )

        items.append(item)
        expandedCategories.insert(selectedCategory.name)

        newItemName = ""
        newItemPrice = ""
        selectedCategory = .uncategorized
    }

    func toggleCompleted(_ item: GroceryItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        items[index].completed.toggle()
        items[index].lastUpdated = Date()
    }

    func toggleCategory(_ category: GroceryCategory) {
        if expandedCategories.contains(category.name) {
            expandedCategories.remove(category.name)
        } else {
            expandedCategories.insert(category.name)
        }
    }

    func toggleCompletedSection() {
        isCompletedSectionExpanded.toggle()
    }

    func deleteCompletedItems() {
        items.removeAll { $0.completed }
    }
}
