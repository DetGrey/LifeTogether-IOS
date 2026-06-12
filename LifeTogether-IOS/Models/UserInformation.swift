//
//  UserInformation.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import Foundation

struct UserInformation: Equatable, Sendable {
    let uid: String
    let email: String
    let name: String
    let lastUpdated: Date
    let birthday: Date?
    let familyId: String?
    let imageUrl: String?
}
