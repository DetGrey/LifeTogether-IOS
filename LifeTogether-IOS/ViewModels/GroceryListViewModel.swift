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
    private(set) var items: [GroceryItem] = []
    private(set) var groceryCategories: [GroceryCategory] = []
    private(set) var allSuggestions: [GrocerySuggestion] = []
    private(set) var isLoading = true

    var newItemName = ""
    var newItemPrice = ""
    var selectedCategory: GroceryCategory = .uncategorized
    var expandedCategories: Set<String> = []
    var isCompletedSectionExpanded = false
    var errorMessage: String?

    @ObservationIgnored private let groceryRepository: GroceryRepository
    @ObservationIgnored private var itemsListener: ListenerRegistration?
    @ObservationIgnored private var categoriesListener: ListenerRegistration?
    @ObservationIgnored private var suggestionsListener: ListenerRegistration?
    @ObservationIgnored private var currentFamilyId: String?

    init(groceryRepository: GroceryRepository? = nil, initialSuggestions: [GrocerySuggestion] = []) {
        self.groceryRepository = groceryRepository ?? FirestoreGroceryRepository()
        self.allSuggestions = initialSuggestions
        observeCategories()
        observeSuggestions()
    }

    deinit {
        itemsListener?.remove()
        categoriesListener?.remove()
        suggestionsListener?.remove()
    }

    // MARK: - Computed

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
            .compactMap { _, groupItems -> (category: GroceryCategory, items: [GroceryItem])? in
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

    // MARK: - Session

    func updateFamilyId(_ familyId: String?) {
        guard familyId != currentFamilyId else { return }
        currentFamilyId = familyId
        itemsListener?.remove()
        itemsListener = nil

        guard let familyId else {
            items = []
            isLoading = false
            return
        }

        isLoading = true
        itemsListener = groceryRepository.observeGroceryItems(familyId: familyId) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let items):
                    self.items = items
                    items.forEach { self.expandedCategories.insert($0.category.name) }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Actions

    func addItem() {
        guard canAddItem, let familyId = currentFamilyId else { return }

        let item = GroceryItem(
            familyId: familyId,
            itemName: newItemName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            approxPrice: Float(newItemPrice)
        )

        newItemName = ""
        newItemPrice = ""
        selectedCategory = .uncategorized

        Task {
            do {
                try await groceryRepository.saveGroceryItem(item)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func applySuggestion(_ suggestion: GrocerySuggestion) {
        newItemName = suggestion.suggestionName
        selectedCategory = suggestion.category
        newItemPrice = suggestion.approxPrice?.groceryPriceInputString ?? ""
        addItem()
    }

    func toggleCompleted(_ item: GroceryItem) {
        var updated = item
        updated.completed.toggle()
        updated.lastUpdated = Date()

        Task {
            do {
                try await groceryRepository.toggleGroceryItemCompleted(updated)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
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
        let ids = completedItems.map(\.id)
        guard !ids.isEmpty else { return }

        Task {
            do {
                try await groceryRepository.deleteGroceryItems(ids: ids)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Private

    private func observeCategories() {
        categoriesListener = groceryRepository.observeCategories { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success(let categories):
                    let remote = categories
                        .filter { $0.name != GroceryCategory.uncategorized.name }
                        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                    self.groceryCategories = [.uncategorized] + remote
                case .failure:
                    self.groceryCategories = [.uncategorized]
                }
            }
        }
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
