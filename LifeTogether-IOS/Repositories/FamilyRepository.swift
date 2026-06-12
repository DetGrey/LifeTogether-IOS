//
//  FamilyRepository.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

protocol FamilyRepository {
    @discardableResult
    func observeFamilyInformation(
        familyId: String,
        onChange: @escaping (Result<FamilyInformation, Error>) -> Void
    ) -> ListenerRegistration
}

final class FirestoreFamilyRepository: FamilyRepository {
    private let configuredDb: Firestore?

    init(db: Firestore? = nil) {
        configuredDb = db
    }

    func observeFamilyInformation(
        familyId: String,
        onChange: @escaping (Result<FamilyInformation, Error>) -> Void
    ) -> ListenerRegistration {
        guard FirebaseApp.app() != nil else {
            onChange(.failure(FamilyRepositoryError.firebaseNotConfigured))
            return NoOpListenerRegistration()
        }

        let db = configuredDb ?? Firestore.firestore()

        return db.collection("families")
            .document(familyId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange(.failure(error))
                    return
                }

                guard let snapshot, snapshot.exists, let data = snapshot.data() else {
                    onChange(.failure(FamilyRepositoryError.familyNotFound))
                    return
                }

                onChange(
                    .success(
                        FamilyInformation(
                            familyId: snapshot.documentID,
                            members: Self.mapFamilyMembers(data["members"]),
                            lastUpdated: (data["lastUpdated"] as? Timestamp)?.dateValue() ?? Date(timeIntervalSince1970: 0),
                            imageUrl: (data["imageUrl"] as? String)?.nonEmpty,
                            togetherSince: (data["togetherSince"] as? Timestamp)?.dateValue()
                        )
                    )
                )
            }
    }

    private static func mapFamilyMembers(_ value: Any?) -> [FamilyMember] {
        guard let membersData = value as? [[String: Any]] else { return [] }

        return membersData.compactMap { member in
            guard
                let uid = (member["uid"] as? String)?.nonEmpty,
                let name = (member["name"] as? String)?.nonEmpty
            else {
                return nil
            }

            return FamilyMember(
                uid: uid,
                name: name,
                imageUrl: (member["imageUrl"] as? String)?.nonEmpty
            )
        }
    }
}

enum FamilyRepositoryError: LocalizedError {
    case firebaseNotConfigured
    case familyNotFound

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase is not configured."
        case .familyNotFound:
            return "Family could not be loaded."
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
