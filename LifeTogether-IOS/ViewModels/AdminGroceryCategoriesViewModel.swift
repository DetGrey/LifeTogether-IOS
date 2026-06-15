//
//  AdminGroceryCategoriesViewModel.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 15/06/2026.
//

import FirebaseFirestore
import Foundation
import Observation

@MainActor
@Observable
final class AdminGroceryCategoriesViewModel {
    var categories: [GroceryCategory]
    var newCategory = ""
    var selectedCategory: GroceryCategory?
    var errorMessage: String?

    @ObservationIgnored private let groceryRepository: GroceryRepository
    @ObservationIgnored private var categoriesListener: ListenerRegistration?

    init(
        groceryRepository: GroceryRepository? = nil,
        initialCategories: [GroceryCategory] = [],
        observesCategories: Bool = true
    ) {
        self.groceryRepository = groceryRepository ?? FirestoreGroceryRepository()
        categories = Self.sortedCategories(initialCategories)

        if observesCategories {
            observeCategories()
        }
    }

    var canAddCategory: Bool {
        !newCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func addCategory() {
        guard canAddCategory else { return }

        guard let category = parseCategory(newCategory) else {
            errorMessage = "Please enter both an emoji and a category name"
            return
        }

        errorMessage = nil

        Task {
            do {
                try await groceryRepository.addCategory(category)
                newCategory = ""
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func selectCategoryForDelete(_ category: GroceryCategory) {
        guard category.name != GroceryCategory.uncategorized.name else { return }

        selectedCategory = category
    }

    func dismissDeleteCategory() {
        selectedCategory = nil
    }

    func confirmDeleteCategory() {
        guard let selectedCategory else { return }

        errorMessage = nil

        Task {
            do {
                try await groceryRepository.deleteCategory(selectedCategory)
                self.selectedCategory = nil
            } catch {
                self.selectedCategory = nil
                errorMessage = error.localizedDescription
            }
        }
    }

    func canDelete(_ category: GroceryCategory) -> Bool {
        category.name != GroceryCategory.uncategorized.name
    }

    private func observeCategories() {
        categoriesListener?.remove()

        categoriesListener = groceryRepository.observeCategories { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .success(let categories):
                    self.categories = Self.sortedCategories(categories)
                case .failure(let error):
                    self.categories = [GroceryCategory.uncategorized]
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func parseCategory(_ value: String) -> GroceryCategory? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(maxSplits: 1, omittingEmptySubsequences: true) { $0.isWhitespace }

        guard parts.count == 2 else { return nil }

        let emoji = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
        let name = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)

        guard !emoji.isEmpty, !name.isEmpty else { return nil }

        return GroceryCategory(emoji: emoji, name: name)
    }

    private static func sortedCategories(_ categories: [GroceryCategory]) -> [GroceryCategory] {
        let remoteCategories = categories
            .filter { $0.name != GroceryCategory.uncategorized.name }
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }

        return [GroceryCategory.uncategorized] + remoteCategories
    }
}
