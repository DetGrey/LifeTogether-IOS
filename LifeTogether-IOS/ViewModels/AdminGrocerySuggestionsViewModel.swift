//
//  AdminGrocerySuggestionsViewModel.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 15/06/2026.
//

import FirebaseFirestore
import Foundation
import Observation

@MainActor
@Observable
final class AdminGrocerySuggestionsViewModel {
    var categories: [GroceryCategory]
    var suggestions: [GrocerySuggestion]
    var expandedCategories: Set<String> = []
    var selectedSuggestion: GrocerySuggestion?
    var newSuggestionText = ""
    var newSuggestionPrice = ""
    var selectedCategory: GroceryCategory = .uncategorized
    var editingSuggestionId: String?
    var errorMessage: String?

    @ObservationIgnored private let groceryRepository: GroceryRepository
    @ObservationIgnored private var categoriesListener: ListenerRegistration?
    @ObservationIgnored private var suggestionsListener: ListenerRegistration?

    init(
        groceryRepository: GroceryRepository? = nil,
        initialCategories: [GroceryCategory] = [],
        initialSuggestions: [GrocerySuggestion] = [],
        observesData: Bool = true
    ) {
        self.groceryRepository = groceryRepository ?? FirestoreGroceryRepository()
        categories = Self.sortedCategories(initialCategories)
        suggestions = Self.sortedSuggestions(initialSuggestions)

        if observesData {
            observeData()
        }
    }

    var isEditing: Bool {
        editingSuggestionId != nil
    }

    var canSaveSuggestion: Bool {
        !newSuggestionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var suggestionsByCategory: [(category: GroceryCategory, suggestions: [GrocerySuggestion])] {
        let grouped = Dictionary(grouping: suggestions) { $0.category.name }
        let categoriesFromSuggestions = grouped.compactMap { _, suggestions in
            suggestions.first?.category
        }
        let visibleCategories = Self.sortedCategories(categoriesFromSuggestions)

        return visibleCategories.compactMap { category in
            guard let categorySuggestions = grouped[category.name], !categorySuggestions.isEmpty else { return nil }
            return (category, categorySuggestions)
        }
    }

    func toggleCategory(_ category: GroceryCategory) {
        if expandedCategories.contains(category.name) {
            expandedCategories.remove(category.name)
        } else {
            expandedCategories.insert(category.name)
        }
    }

    func startEditing(_ suggestion: GrocerySuggestion) {
        editingSuggestionId = suggestion.id
        newSuggestionText = suggestion.suggestionName
        newSuggestionPrice = suggestion.approxPrice?.groceryPriceInputString ?? ""
        selectedCategory = suggestion.category
        errorMessage = nil
    }

    func selectSuggestionForDelete(_ suggestion: GrocerySuggestion) {
        selectedSuggestion = suggestion
    }

    func dismissDeleteSuggestion() {
        selectedSuggestion = nil
    }

    func saveSuggestion() {
        guard canSaveSuggestion else {
            errorMessage = "Please enter a suggestion first"
            return
        }

        let suggestion = GrocerySuggestion(
            id: editingSuggestionId ?? UUID().uuidString,
            suggestionName: newSuggestionText.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            approxPrice: Float(newSuggestionPrice.trimmingCharacters(in: .whitespacesAndNewlines))
        )

        errorMessage = nil

        Task {
            do {
                try await groceryRepository.saveGrocerySuggestion(suggestion)
                clearSuggestionDraft()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func confirmDeleteSuggestion() {
        guard let selectedSuggestion else { return }

        errorMessage = nil

        Task {
            do {
                try await groceryRepository.deleteGrocerySuggestion(selectedSuggestion)
                self.selectedSuggestion = nil
            } catch {
                self.selectedSuggestion = nil
                errorMessage = error.localizedDescription
            }
        }
    }

    private func observeData() {
        categoriesListener?.remove()
        suggestionsListener?.remove()

        categoriesListener = groceryRepository.observeCategories { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .success(let categories):
                    self.categories = Self.sortedCategories(categories)
                    if !self.categories.contains(where: { $0.name == self.selectedCategory.name }) {
                        self.selectedCategory = .uncategorized
                    }
                case .failure(let error):
                    self.categories = [.uncategorized]
                    self.selectedCategory = .uncategorized
                    self.errorMessage = error.localizedDescription
                }
            }
        }

        suggestionsListener = groceryRepository.observeGrocerySuggestions { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .success(let suggestions):
                    self.suggestions = Self.sortedSuggestions(suggestions)
                case .failure(let error):
                    self.suggestions = []
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func clearSuggestionDraft() {
        editingSuggestionId = nil
        selectedCategory = .uncategorized
        newSuggestionText = ""
        newSuggestionPrice = ""
    }

    private static func sortedCategories(_ categories: [GroceryCategory]) -> [GroceryCategory] {
        let remoteCategories = categories
            .filter { $0.name != GroceryCategory.uncategorized.name }
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }

        return [GroceryCategory.uncategorized] + remoteCategories
    }

    private static func sortedSuggestions(_ suggestions: [GrocerySuggestion]) -> [GrocerySuggestion] {
        suggestions.sorted {
            let categoryComparison = $0.category.name.localizedCaseInsensitiveCompare($1.category.name)
            if categoryComparison == .orderedSame {
                return $0.suggestionName.localizedCaseInsensitiveCompare($1.suggestionName) == .orderedAscending
            }

            return categoryComparison == .orderedAscending
        }
    }
}
