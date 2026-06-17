//
//  GroceryListViewModel.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import FirebaseFirestore
import Foundation
import Observation

@MainActor
@Observable
final class GroceryListViewModel {
    var items: [GroceryItem]
    var newItemName = ""
    var newItemPrice = ""
    var selectedCategory: GroceryCategory = .uncategorized
    var expandedCategories: Set<String>
    var isCompletedSectionExpanded = false

    private(set) var allSuggestions: [GrocerySuggestion] = []

    let groceryCategories: [GroceryCategory] = [
        .uncategorized,
        GroceryCategory(emoji: "🥦", name: "Vegetables"),
        GroceryCategory(emoji: "🍎", name: "Fruits"),
        GroceryCategory(emoji: "🥛", name: "Dairy"),
        GroceryCategory(emoji: "🍞", name: "Bread"),
        GroceryCategory(emoji: "🧼", name: "Household")
    ]

    @ObservationIgnored private let groceryRepository: GroceryRepository
    @ObservationIgnored private var suggestionsListener: ListenerRegistration?

    init(groceryRepository: GroceryRepository? = nil, initialSuggestions: [GrocerySuggestion] = []) {
        self.groceryRepository = groceryRepository ?? FirestoreGroceryRepository()
        self.allSuggestions = initialSuggestions

        self.items = [
            GroceryItem(itemName: "Bananas", category: GroceryCategory(emoji: "🍎", name: "Fruits"), approxPrice: 12),
            GroceryItem(itemName: "Milk", category: GroceryCategory(emoji: "🥛", name: "Dairy"), approxPrice: 15),
            GroceryItem(itemName: "Dish soap", category: GroceryCategory(emoji: "🧼", name: "Household")),
            GroceryItem(itemName: "Potatoes", category: GroceryCategory(emoji: "🥦", name: "Vegetables"), completed: true)
        ]

        self.expandedCategories = Set(groceryCategories.map(\.name))

        observeSuggestions()
    }

    deinit {
        suggestionsListener?.remove()
    }

    var currentSuggestions: [GrocerySuggestion] {
        searchGrocerySuggestions(query: newItemName, suggestions: allSuggestions)
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
        let grouped = Dictionary(grouping: items.filter { !$0.completed }) { $0.category.name }
        return grouped
            .compactMap { name, groupItems -> (category: GroceryCategory, items: [GroceryItem])? in
                guard let category = groupItems.first?.category else { return nil }
                let sorted = groupItems.sorted {
                    $0.itemName.localizedCaseInsensitiveCompare($1.itemName) == .orderedAscending
                }
                return (category, sorted)
            }
            .sorted { $0.category.name.localizedCaseInsensitiveCompare($1.category.name) == .orderedAscending }
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

    func applySuggestion(_ suggestion: GrocerySuggestion) {
        newItemName = suggestion.suggestionName
        selectedCategory = suggestion.category
        newItemPrice = suggestion.approxPrice?.groceryPriceInputString ?? ""
        addItem()
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

    private func observeSuggestions() {
        suggestionsListener = groceryRepository.observeGrocerySuggestions { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success(let suggestions):
                    self.allSuggestions = suggestions.sorted {
                        $0.suggestionName.localizedCaseInsensitiveCompare($1.suggestionName) == .orderedAscending
                    }
                case .failure:
                    self.allSuggestions = []
                }
            }
        }
    }
}
