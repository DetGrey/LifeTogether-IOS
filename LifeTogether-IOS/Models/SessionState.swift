//
//  SessionState.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import Foundation

enum SessionState: Equatable, Sendable {
    case loading
    case unauthenticated
    case authenticated(user: UserInformation, isAdmin: Bool)

    var authenticatedUser: UserInformation? {
        if case .authenticated(let user, _) = self {
            return user
        }

        return nil
    }

    var isAdmin: Bool {
        if case .authenticated(_, let isAdmin) = self {
            return isAdmin
        }

        return false
    }
}
