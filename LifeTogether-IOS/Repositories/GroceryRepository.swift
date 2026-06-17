//
//  GroceryRepository.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 15/06/2026.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

protocol GroceryRepository {
    @discardableResult
    func observeGroceryItems(
        familyId: String,
        onChange: @escaping (Result<[GroceryItem], Error>) -> Void
    ) -> ListenerRegistration

    func saveGroceryItem(_ item: GroceryItem) async throws

    func toggleGroceryItemCompleted(_ item: GroceryItem) async throws

    func deleteGroceryItems(ids: [String]) async throws

    @discardableResult
    func observeCategories(
        onChange: @escaping (Result<[GroceryCategory], Error>) -> Void
    ) -> ListenerRegistration

    func addCategory(_ category: GroceryCategory) async throws

    func deleteCategory(_ category: GroceryCategory) async throws

    @discardableResult
    func observeGrocerySuggestions(
        onChange: @escaping (Result<[GrocerySuggestion], Error>) -> Void
    ) -> ListenerRegistration

    func saveGrocerySuggestion(_ suggestion: GrocerySuggestion) async throws

    func deleteGrocerySuggestion(_ suggestion: GrocerySuggestion) async throws
}

final class FirestoreGroceryRepository: GroceryRepository {
    private static let legacyFallbackDate = Date(timeIntervalSince1970: 0)

    private let configuredDb: Firestore?

    init(db: Firestore? = nil) {
        configuredDb = db
    }

    func observeGroceryItems(
        familyId: String,
        onChange: @escaping (Result<[GroceryItem], Error>) -> Void
    ) -> ListenerRegistration {
        guard FirebaseApp.app() != nil else {
            onChange(.failure(GroceryRepositoryError.firebaseNotConfigured))
            return NoOpListenerRegistration()
        }

        let db = configuredDb ?? Firestore.firestore()

        return db.collection("grocery_list")
            .whereField("familyId", isEqualTo: familyId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange(.failure(error))
                    return
                }

                guard let snapshot else {
                    onChange(.failure(GroceryRepositoryError.itemsNotFound))
                    return
                }

                let items = snapshot.documents.compactMap { document in
                    Self.mapGroceryItem(documentId: document.documentID, data: document.data())
                }

                onChange(.success(items))
            }
    }

    func saveGroceryItem(_ item: GroceryItem) async throws {
        guard FirebaseApp.app() != nil else {
            throw GroceryRepositoryError.firebaseNotConfigured
        }

        let db = configuredDb ?? Firestore.firestore()
        let stamped = GroceryItem(
            id: item.id,
            familyId: item.familyId,
            itemName: item.itemName,
            category: item.category,
            completed: item.completed,
            approxPrice: item.approxPrice,
            lastUpdated: Date()
        )

        try await db.collection("grocery_list")
            .document(stamped.id)
            .setData(Self.groceryItemData(stamped))
    }

    func toggleGroceryItemCompleted(_ item: GroceryItem) async throws {
        guard FirebaseApp.app() != nil else {
            throw GroceryRepositoryError.firebaseNotConfigured
        }

        let db = configuredDb ?? Firestore.firestore()

        try await db.collection("grocery_list")
            .document(item.id)
            .updateData([
                "completed": item.completed,
                "lastUpdated": Timestamp(date: item.lastUpdated)
            ])
    }

    func deleteGroceryItems(ids: [String]) async throws {
        guard FirebaseApp.app() != nil else {
            throw GroceryRepositoryError.firebaseNotConfigured
        }

        let db = configuredDb ?? Firestore.firestore()
        let batch = db.batch()

        ids.forEach { id in
            batch.deleteDocument(db.collection("grocery_list").document(id))
        }

        try await batch.commit()
    }

    func observeCategories(
        onChange: @escaping (Result<[GroceryCategory], Error>) -> Void
    ) -> ListenerRegistration {
        guard FirebaseApp.app() != nil else {
            onChange(.failure(GroceryRepositoryError.firebaseNotConfigured))
            return NoOpListenerRegistration()
        }

        let db = configuredDb ?? Firestore.firestore()

        return db.collection("categories")
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange(.failure(error))
                    return
                }

                guard let snapshot else {
                    onChange(.failure(GroceryRepositoryError.categoriesNotFound))
                    return
                }

                let categories = snapshot.documents.compactMap { document in
                    Self.mapCategory(data: document.data())
                }

                onChange(.success(categories))
            }
    }

    func addCategory(_ category: GroceryCategory) async throws {
        guard FirebaseApp.app() != nil else {
            throw GroceryRepositoryError.firebaseNotConfigured
        }

        let db = configuredDb ?? Firestore.firestore()
        let stampedCategory = GroceryCategory(
            emoji: category.emoji,
            name: category.name,
            lastUpdated: Date()
        )

        _ = try await db.collection("categories")
            .addDocument(data: Self.categoryData(stampedCategory))
    }

    func deleteCategory(_ category: GroceryCategory) async throws {
        guard FirebaseApp.app() != nil else {
            throw GroceryRepositoryError.firebaseNotConfigured
        }

        let db = configuredDb ?? Firestore.firestore()
        let snapshot = try await db.collection("categories")
            .whereField("name", isEqualTo: category.name)
            .getDocuments()

        guard let document = snapshot.documents.first else { return }
        try await document.reference.delete()
    }

    func observeGrocerySuggestions(
        onChange: @escaping (Result<[GrocerySuggestion], Error>) -> Void
    ) -> ListenerRegistration {
        guard FirebaseApp.app() != nil else {
            onChange(.failure(GroceryRepositoryError.firebaseNotConfigured))
            return NoOpListenerRegistration()
        }

        let db = configuredDb ?? Firestore.firestore()

        return db.collection("grocery_suggestions")
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange(.failure(error))
                    return
                }

                guard let snapshot else {
                    onChange(.failure(GroceryRepositoryError.suggestionsNotFound))
                    return
                }

                let suggestions = snapshot.documents.compactMap { document in
                    Self.mapSuggestion(documentId: document.documentID, data: document.data())
                }

                onChange(.success(suggestions))
            }
    }

    func saveGrocerySuggestion(_ suggestion: GrocerySuggestion) async throws {
        guard FirebaseApp.app() != nil else {
            throw GroceryRepositoryError.firebaseNotConfigured
        }

        let db = configuredDb ?? Firestore.firestore()
        let stampedSuggestion = GrocerySuggestion(
            id: suggestion.id,
            suggestionName: suggestion.suggestionName,
            category: suggestion.category,
            approxPrice: suggestion.approxPrice,
            lastUpdated: Date()
        )

        try await db.collection("grocery_suggestions")
            .document(stampedSuggestion.id)
            .setData(Self.suggestionData(stampedSuggestion))
    }

    func deleteGrocerySuggestion(_ suggestion: GrocerySuggestion) async throws {
        guard FirebaseApp.app() != nil else {
            throw GroceryRepositoryError.firebaseNotConfigured
        }

        let db = configuredDb ?? Firestore.firestore()

        try await db.collection("grocery_suggestions")
            .document(suggestion.id)
            .delete()
    }

    private static func mapGroceryItem(documentId: String, data: [String: Any]) -> GroceryItem? {
        guard
            let familyId = (data["familyId"] as? String)?.nonEmpty,
            let itemName = (data["itemName"] as? String)?.nonEmpty,
            let categoryData = data["category"] as? [String: Any],
            let category = mapCategory(data: categoryData)
        else {
            return nil
        }

        return GroceryItem(
            id: documentId,
            familyId: familyId,
            itemName: itemName,
            category: category,
            completed: data["completed"] as? Bool ?? false,
            approxPrice: (data["approxPrice"] as? NSNumber)?.floatValue,
            lastUpdated: firestoreDate(data["lastUpdated"]) ?? legacyFallbackDate
        )
    }

    private static func groceryItemData(_ item: GroceryItem) -> [String: Any] {
        var data: [String: Any] = [
            "familyId": item.familyId,
            "itemName": item.itemName,
            "completed": item.completed,
            "category": categoryData(item.category),
            "lastUpdated": Timestamp(date: item.lastUpdated)
        ]

        if let approxPrice = item.approxPrice {
            data["approxPrice"] = approxPrice
        }

        return data
    }

    private static func mapCategory(data: [String: Any]) -> GroceryCategory? {
        guard
            let emoji = (data["emoji"] as? String)?.nonEmpty,
            let name = (data["name"] as? String)?.nonEmpty
        else {
            return nil
        }

        return GroceryCategory(
            emoji: emoji,
            name: name,
            lastUpdated: firestoreDate(data["lastUpdated"]) ?? legacyFallbackDate
        )
    }

    private static func categoryData(_ category: GroceryCategory) -> [String: Any] {
        [
            "emoji": category.emoji,
            "name": category.name,
            "lastUpdated": Timestamp(date: category.lastUpdated)
        ]
    }

    private static func mapSuggestion(documentId: String, data: [String: Any]) -> GrocerySuggestion? {
        guard
            let suggestionName = (data["suggestionName"] as? String)?.nonEmpty,
            let categoryData = data["category"] as? [String: Any],
            let category = mapCategory(data: categoryData)
        else {
            return nil
        }

        return GrocerySuggestion(
            id: documentId,
            suggestionName: suggestionName,
            category: category,
            approxPrice: (data["approxPrice"] as? NSNumber)?.floatValue,
            lastUpdated: firestoreDate(data["lastUpdated"]) ?? legacyFallbackDate
        )
    }

    private static func suggestionData(_ suggestion: GrocerySuggestion) -> [String: Any] {
        var data: [String: Any] = [
            "suggestionName": suggestion.suggestionName,
            "category": categoryData(suggestion.category),
            "lastUpdated": Timestamp(date: suggestion.lastUpdated)
        ]

        if let approxPrice = suggestion.approxPrice {
            data["approxPrice"] = approxPrice
        }

        return data
    }
}

enum GroceryRepositoryError: LocalizedError {
    case firebaseNotConfigured
    case itemsNotFound
    case categoriesNotFound
    case suggestionsNotFound

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase is not configured."
        case .itemsNotFound:
            return "Grocery items could not be loaded."
        case .categoriesNotFound:
            return "Grocery categories could not be loaded."
        case .suggestionsNotFound:
            return "Grocery suggestions could not be loaded."
        }
    }
}

private final class NoOpListenerRegistration: NSObject, ListenerRegistration {
    func remove() {
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
