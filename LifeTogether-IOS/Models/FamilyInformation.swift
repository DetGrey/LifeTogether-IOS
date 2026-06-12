//
//  FamilyInformation.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import Foundation

struct FamilyInformation: Equatable, Sendable {
    let familyId: String
    let members: [FamilyMember]
    let lastUpdated: Date
    let imageUrl: String?
    let togetherSince: Date?
}

struct FamilyMember: Equatable, Sendable, Identifiable {
    let uid: String
    let name: String
    let imageUrl: String?

    var id: String {
        uid
    }
}
