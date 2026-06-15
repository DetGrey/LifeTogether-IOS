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

    @discardableResult
    func observeAdminUids(
        onChange: @escaping (Result<[String], Error>) -> Void
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
                    if snapshot.metadata.isFromCache {
                        return
                    }

                    onChange(.failure(error))
                }
            }
    }

    func observeAdminUids(
        onChange: @escaping (Result<[String], Error>) -> Void
    ) -> ListenerRegistration {
        let db = configuredDb ?? Firestore.firestore()

        return db.collection("app_config")
            .document("admins")
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange(.failure(error))
                    return
                }

                guard let snapshot, snapshot.exists else {
                    onChange(.failure(UserRepositoryError.adminsNotFound))
                    return
                }

                do {
                    onChange(.success(try Self.mapAdminUids(snapshot.get("adminUids"))))
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

        let lastUpdatedValue = data["lastUpdated"]
        guard let lastUpdated = firestoreDate(lastUpdatedValue) else {
            throw UserRepositoryError.invalidDateField(
                "lastUpdated",
                actualType: firestoreValueTypeDescription(lastUpdatedValue)
            )
        }

        return UserInformation(
            uid: uid,
            email: email,
            name: name,
            lastUpdated: lastUpdated,
            birthday: firestoreDate(data["birthday"]),
            familyId: (data["familyId"] as? String)?.nonEmpty,
            imageUrl: (data["imageUrl"] as? String)?.nonEmpty
        )
    }

    private static func mapAdminUids(_ value: Any?) throws -> [String] {
        guard let values = value as? [String] else {
            throw UserRepositoryError.missingRequiredField("adminUids")
        }

        var seenUids = Set<String>()
        return values.compactMap { value in
            guard let uid = value.nonEmpty, seenUids.insert(uid).inserted else { return nil }
            return uid
        }
    }
}

enum UserRepositoryError: LocalizedError {
    case userNotFound
    case adminsNotFound
    case missingRequiredField(String)
    case invalidDateField(String, actualType: String)

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User profile could not be loaded."
        case .adminsNotFound:
            return "Admin configuration could not be loaded."
        case .missingRequiredField(let field):
            return "User profile is missing \(field)."
        case .invalidDateField(let field, let actualType):
            return "User profile field \(field) is not a valid date. Received \(actualType)."
        }
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
