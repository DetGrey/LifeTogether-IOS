//
//  AuthSession.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import FirebaseAuth
import FirebaseCore
import Foundation
import Observation

@MainActor
@Observable
final class AuthSession {
    private var listenerHandle: AuthStateDidChangeListenerHandle?

    var user: User?

    var isLoggedIn: Bool {
        user != nil
    }

    init() {
        guard FirebaseApp.app() != nil else { return }

        user = Auth.auth().currentUser
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        guard FirebaseApp.app() != nil else {
            throw NSError(
                domain: "LifeTogether.AuthSession",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Firebase is not configured."]
            )
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
