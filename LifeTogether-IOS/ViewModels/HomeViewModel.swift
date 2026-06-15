//
//  HomeViewModel.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 15/06/2026.
//

import FirebaseFirestore
import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var familyInformation: FamilyInformation?
    var statusMessage: String?

    @ObservationIgnored private let familyRepository: FamilyRepository
    @ObservationIgnored private var familyListener: ListenerRegistration?
    @ObservationIgnored private var observedFamilyId: String?

    var familyImageUrl: String? {
        familyInformation?.imageUrl
    }

    init(familyRepository: FamilyRepository? = nil) {
        self.familyRepository = familyRepository ?? FirestoreFamilyRepository()
    }

    func update(for sessionState: SessionState) {
        switch sessionState {
        case .loading:
            statusMessage = nil
            observeFamily(familyId: nil)
        case .unauthenticated:
            statusMessage = "Please login to use the app"
            observeFamily(familyId: nil)
        case .authenticated(let user):
            statusMessage = user.familyId == nil ? "Please create or join a family to save your data" : nil
            observeFamily(familyId: user.familyId)
        }
    }

    private func observeFamily(familyId: String?) {
        guard observedFamilyId != familyId else { return }

        familyListener?.remove()
        familyListener = nil
        observedFamilyId = familyId
        familyInformation = nil

        guard let familyId else { return }

        familyListener = familyRepository.observeFamilyInformation(familyId: familyId) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .success(let family):
                    self.familyInformation = family
                case .failure:
                    self.familyInformation = nil
                }
            }
        }
    }
}
