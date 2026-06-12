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
    case authenticated(user: UserInformation)

    var authenticatedUser: UserInformation? {
        if case .authenticated(let user) = self {
            return user
        }

        return nil
    }
}
