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
    func observeCategories(
        onChange: @escaping (Result<[GroceryCategory], Error>) -> Void
    ) -> ListenerRegistration

    func addCategory(_ category: GroceryCategory) async throws

    func deleteCategory(_ category: GroceryCategory) async throws
}

final class FirestoreGroceryRepository: GroceryRepository {
    private let configuredDb: Firestore?

    init(db: Firestore? = nil) {
        configuredDb = db
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
            lastUpdated: (data["lastUpdated"] as? Timestamp)?.dateValue() ?? Date(timeIntervalSince1970: 0)
        )
    }

    private static func categoryData(_ category: GroceryCategory) -> [String: Any] {
        [
            "emoji": category.emoji,
            "name": category.name,
            "lastUpdated": Timestamp(date: category.lastUpdated)
        ]
    }
}

enum GroceryRepositoryError: LocalizedError {
    case firebaseNotConfigured
    case categoriesNotFound

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase is not configured."
        case .categoriesNotFound:
            return "Grocery categories could not be loaded."
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
