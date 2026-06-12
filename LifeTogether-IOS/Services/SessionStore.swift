//
//  SessionStore.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import Observation

@MainActor
@Observable
final class SessionStore {
    private let userRepository: UserRepository
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?
    private var pendingSignInContinuation: CheckedContinuation<Void, Error>?

    var state: SessionState = .loading
    var lastErrorMessage: String?

    var currentUser: UserInformation? {
        state.authenticatedUser
    }

    var isLoggedIn: Bool {
        currentUser != nil
    }

    var uid: String? {
        currentUser?.uid
    }

    var familyId: String? {
        currentUser?.familyId
    }

    init(
        userRepository: UserRepository? = nil,
        initialState: SessionState = .loading,
        observesFirebase: Bool = true
    ) {
        self.userRepository = userRepository ?? FirestoreUserRepository()
        state = initialState

        guard observesFirebase else { return }

        guard FirebaseApp.app() != nil else {
            state = .unauthenticated
            lastErrorMessage = SessionStoreError.firebaseNotConfigured.localizedDescription
            return
        }

        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.handleAuthUser(user)
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        guard FirebaseApp.app() != nil else {
            throw SessionStoreError.firebaseNotConfigured
        }

        guard pendingSignInContinuation == nil else {
            throw SessionStoreError.signInAlreadyInProgress
        }

        lastErrorMessage = nil
        state = .loading

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            pendingSignInContinuation = continuation
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }

                    if let error {
                        self.state = .unauthenticated
                        self.finishPendingSignIn(with: .failure(error))
                        return
                    }

                    if let uid = result?.user.uid {
                        self.observeUser(uid: uid)
                    } else {
                        self.state = .unauthenticated
                        self.finishPendingSignIn(with: .failure(SessionStoreError.missingAuthenticatedUser))
                    }
                }
            }
        }
    }

    func signOut() throws {
        userListener?.remove()
        userListener = nil
        try Auth.auth().signOut()
        state = .unauthenticated
        lastErrorMessage = nil
    }

    private func handleAuthUser(_ user: User?) {
        userListener?.remove()
        userListener = nil

        guard let user else {
            state = .unauthenticated
            lastErrorMessage = nil
            return
        }

        state = .loading
        observeUser(uid: user.uid)
    }

    private func observeUser(uid: String) {
        userListener?.remove()

        userListener = userRepository.observeUserInformation(uid: uid) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .success(let user):
                    self.lastErrorMessage = nil
                    self.state = .authenticated(user: user)
                    self.finishPendingSignIn(with: .success(()))
                case .failure(let error):
                    self.lastErrorMessage = error.localizedDescription
                    self.state = .unauthenticated
                    self.finishPendingSignIn(with: .failure(error))
                }
            }
        }
    }

    private func finishPendingSignIn(with result: Result<Void, Error>) {
        guard let continuation = pendingSignInContinuation else { return }

        pendingSignInContinuation = nil

        switch result {
        case .success:
            continuation.resume()
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}

enum SessionStoreError: LocalizedError {
    case firebaseNotConfigured
    case missingAuthenticatedUser
    case signInAlreadyInProgress

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase is not configured."
        case .missingAuthenticatedUser:
            return "Authenticated user could not be loaded."
        case .signInAlreadyInProgress:
            return "Sign-in is already in progress."
        }
    }
}

extension SessionStore {
    static var previewUnauthenticated: SessionStore {
        SessionStore(
            initialState: .unauthenticated,
            observesFirebase: false
        )
    }

    static var previewAuthenticated: SessionStore {
        SessionStore(
            initialState: .authenticated(
                user: UserInformation(
                    uid: "preview-uid",
                    email: "ane@example.com",
                    name: "Ane",
                    lastUpdated: Date(),
                    birthday: Calendar.current.date(from: DateComponents(year: 1998, month: 4, day: 23)),
                    familyId: "preview-family",
                    imageUrl: nil
                )
            ),
            observesFirebase: false
        )
    }
}
