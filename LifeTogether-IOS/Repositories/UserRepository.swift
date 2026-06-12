//
//  UserRepository.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import FirebaseFirestore
import Foundation

protocol UserRepository {
    @discardableResult
    func observeUserInformation(
        uid: String,
        onChange: @escaping (Result<UserInformation, Error>) -> Void
    ) -> ListenerRegistration
}

final class FirestoreUserRepository: UserRepository {
    private let configuredDb: Firestore?

    init(db: Firestore? = nil) {
        configuredDb = db
    }

    func observeUserInformation(
        uid: String,
        onChange: @escaping (Result<UserInformation, Error>) -> Void
    ) -> ListenerRegistration {
        let db = configuredDb ?? Firestore.firestore()

        return db.collection("users")
            .document(uid)
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange(.failure(error))
                    return
                }

                guard let snapshot, snapshot.exists, let data = snapshot.data() else {
                    onChange(.failure(UserRepositoryError.userNotFound))
                    return
                }

                do {
                    onChange(.success(try Self.mapUserInformation(documentId: snapshot.documentID, data: data)))
                } catch {
                    onChange(.failure(error))
                }
            }
    }

    private static func mapUserInformation(documentId: String, data: [String: Any]) throws -> UserInformation {
        let uid = (data["uid"] as? String)?.nonEmpty ?? documentId.nonEmpty

        guard let uid else {
            throw UserRepositoryError.missingRequiredField("uid")
        }

        guard let email = (data["email"] as? String)?.nonEmpty else {
            throw UserRepositoryError.missingRequiredField("email")
        }

        guard let name = (data["name"] as? String)?.nonEmpty else {
            throw UserRepositoryError.missingRequiredField("name")
        }

        return UserInformation(
            uid: uid,
            email: email,
            name: name,
            lastUpdated: (data["lastUpdated"] as? Timestamp)?.dateValue() ?? Date(timeIntervalSince1970: 0),
            birthday: (data["birthday"] as? Timestamp)?.dateValue(),
            familyId: (data["familyId"] as? String)?.nonEmpty,
            imageUrl: (data["imageUrl"] as? String)?.nonEmpty
        )
    }
}

enum UserRepositoryError: LocalizedError {
    case userNotFound
    case missingRequiredField(String)

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User profile could not be loaded."
        case .missingRequiredField(let field):
            return "User profile is missing \(field)."
        }
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
