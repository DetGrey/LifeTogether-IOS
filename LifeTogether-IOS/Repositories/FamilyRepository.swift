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

                do {
                    onChange(.success(try Self.mapFamilyInformation(documentId: snapshot.documentID, data: data)))
                } catch {
                    onChange(.failure(error))
                }
            }
    }

    private static func mapFamilyInformation(documentId: String, data: [String: Any]) throws -> FamilyInformation {
        guard let lastUpdated = firestoreDate(data["lastUpdated"]) else {
            throw FamilyRepositoryError.missingRequiredField("lastUpdated")
        }

        guard let membersData = data["members"] as? [[String: Any]] else {
            throw FamilyRepositoryError.missingRequiredField("members")
        }

        return FamilyInformation(
            familyId: documentId,
            members: mapFamilyMembers(membersData),
            lastUpdated: lastUpdated,
            imageUrl: (data["imageUrl"] as? String)?.nonEmpty,
            togetherSince: firestoreDate(data["togetherSince"])
        )
    }

    private static func mapFamilyMembers(_ membersData: [[String: Any]]) -> [FamilyMember] {
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
    case missingRequiredField(String)

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase is not configured."
        case .familyNotFound:
            return "Family could not be loaded."
        case .missingRequiredField(let field):
            return "Family information is missing \(field)."
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
