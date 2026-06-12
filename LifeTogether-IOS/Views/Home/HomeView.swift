//
//  HomeView.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import FirebaseFirestore
import SwiftUI

struct HomeView: View {
    @Environment(SessionStore.self) private var sessionStore
    @State private var navigationPath: [HomeDestination] = []
    @State private var familyImageUrl: String?
    @State private var familyListener: ListenerRegistration?

    private let familyRepository = FirestoreFamilyRepository()
    
    let sectionRows: [HomeTileRow] = [
        HomeTileRow(tiles: [.groceryList, .recipes]),
        HomeTileRow(tiles: [.guides, .gallery, .lists]),
        HomeTileRow(tiles: [.mealPlanner, .tipTracker]),
        HomeTileRow(tiles: [.traveller])
    ]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVStack(spacing: AppSpacing.medium) {
                    Text("1477 days together")
                        .font(.appLabelMedium)
                    
                    ZStack {
                        if let urlString = familyImageUrl, let validURL = URL(string: urlString) {
                            AsyncImage(url: validURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.clear
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(.surfaceSecondary, in: RoundedRectangle(cornerRadius: AppRadius.large))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.large))
                    
                    HStack {
                        //todo status card
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: AppSpacing.small) {
                        ForEach(sectionRows) { row in
                            HStack(spacing: AppSpacing.small) {
                                ForEach(row.tiles) { tile in
                                    FeatureCard(
                                        title: tile.rawValue,
                                        icon: tile.iconName,
                                        onClick: {
                                            navigate(to: tile)
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(AppSpacing.medium)
            .background(.appBackground)
            .appNavigationTitle("LifeTogether")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        navigationPath.append(sessionStore.isLoggedIn ? .profile : .login)
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: AppSizing.iconMedium))
                            .foregroundStyle(.textPrimary)
                    }
                    .accessibilityLabel(sessionStore.isLoggedIn ? "Profile" : "Login")
                }
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .login:
                    LoginView()
                case .profile:
                    ProfileView()
                case .tile(let tile):
                    switch tile {
                    case .groceryList:
                        GroceryListView()
                    case .recipes:
                        Text("Recipes Screen Placeholder")
                    case .guides:
                        Text("Guides Screen Placeholder")
                    case .gallery:
                        Text("Gallery Screen Placeholder")
                    case .tipTracker:
                        Text("Tip Tracker Screen Placeholder")
                    case .lists:
                        Text("Lists Screen Placeholder")
                    case .mealPlanner:
                        Text("Meal Planner Screen Placeholder")
                    case .traveller:
                        Text("Traveller Screen Placeholder")
                    }
                }
            }
            .onChange(of: sessionStore.isLoggedIn) { _, isLoggedIn in
                if !isLoggedIn {
                    stopObservingFamily()
                    navigationPath.removeAll()
                }
            }
            .onAppear {
                observeFamily(familyId: sessionStore.familyId)
            }
            .onChange(of: sessionStore.familyId) { _, familyId in
                observeFamily(familyId: familyId)
            }
        }
    }

    private func navigate(to tile: HomeTile) {
        guard tile != .groceryList || sessionStore.isLoggedIn else { return }

        navigationPath.append(.tile(tile))
    }

    private func observeFamily(familyId: String?) {
        familyListener?.remove()
        familyListener = nil
        familyImageUrl = nil

        guard let familyId else { return }

        familyListener = familyRepository.observeFamilyInformation(familyId: familyId) { result in
            Task { @MainActor in
                switch result {
                case .success(let family):
                    familyImageUrl = family.imageUrl
                case .failure:
                    familyImageUrl = nil
                }
            }
        }
    }

    private func stopObservingFamily() {
        familyListener?.remove()
        familyListener = nil
        familyImageUrl = nil
    }
}

#Preview {
    HomeView()
        .environment(SessionStore.previewAuthenticated)
        .preferredColorScheme(.dark)
}
