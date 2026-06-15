//
//  HomeView.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(SessionStore.self) private var sessionStore
    @State private var viewModel = HomeViewModel()
    @State private var navigationPath: [HomeDestination] = []
    
    let sectionRows: [HomeTileRow] = [
        HomeTileRow(tiles: [.groceryList, .recipes]),
        HomeTileRow(tiles: [.guides, .gallery, .userLists]),
        HomeTileRow(tiles: [.mealPlanner, .tipTracker]),
        HomeTileRow(tiles: [.traveller])
    ]

    let adminSectionRows: [HomeTileRow] = [
        HomeTileRow(tiles: [.adminGroceryCategories, .adminGrocerySuggestions])
    ]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVStack(spacing: AppSpacing.medium) {
                    Text("1477 days together")
                        .font(.appLabelMedium)
                    
                    ZStack {
                        if let urlString = viewModel.familyImageUrl, let validURL = URL(string: urlString) {
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
                    
                    if let statusMessage = viewModel.statusMessage {
                        Text(statusMessage) //todo clickable
                            .padding(.horizontal, AppSpacing.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .foregroundColor(.textOnBrandTertiary)
                            .background(.brandTertiary)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large))
                
                    }
                    
                    VStack(spacing: AppSpacing.small) {
                        ForEach(sectionRows) { row in
                            HStack(spacing: AppSpacing.small) {
                                ForEach(row.tiles) { tile in
                                    FeatureCard(
                                        title: tile.rawValue,
                                        icon: tile.iconName,
                                        isSystemIcon: tile.isSystemIcon,
                                        onClick: {
                                            navigate(to: tile)
                                        }
                                    )
                                }
                            }
                        }
                    }

                    if viewModel.showsAdminSection {
                        Text("Admin features")
                            .font(.appDisplayLarge)
                            .foregroundColor(.brandPrimary)
                            .padding(.top, AppSpacing.small)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: AppSpacing.small) {
                            ForEach(adminSectionRows) { row in
                                HStack(spacing: AppSpacing.small) {
                                    ForEach(row.tiles) { tile in
                                        FeatureCard(
                                            title: tile.rawValue,
                                            icon: tile.iconName,
                                            isSystemIcon: tile.isSystemIcon,
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
                        Image("ic_profile")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: AppSizing.iconMedium, height: AppSizing.iconMedium)
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
                    case .userLists:
                        Text("Lists Screen Placeholder")
                    case .mealPlanner:
                        Text("Meal Planner Screen Placeholder")
                    case .traveller:
                        Text("Traveller Screen Placeholder")
                    case .adminGroceryCategories:
                        AdminGroceryCategoriesView {
                            navigationPath.removeAll()
                        }
                    case .adminGrocerySuggestions:
                        AdminGrocerySuggestionsView {
                            navigationPath.removeAll()
                        }
                    }
                }
            }
            .onChange(of: sessionStore.isLoggedIn) { _, isLoggedIn in
                if !isLoggedIn {
                    navigationPath.removeAll()
                }
            }
            .onChange(of: sessionStore.isAdmin) { _, isAdmin in
                if !isAdmin, navigationPath.contains(where: isAdminDestination) {
                    navigationPath.removeAll()
                }
            }
            .onAppear {
                viewModel.update(for: sessionStore.state)
            }
            .onChange(of: sessionStore.state) { _, state in
                viewModel.update(for: state)
            }
        }
    }

    private func navigate(to tile: HomeTile) {
        guard !tile.requiresLogin || sessionStore.isLoggedIn else { return }
        guard !tile.requiresAdminAccess || sessionStore.isAdmin else { return }

        navigationPath.append(.tile(tile))
    }

    private func isAdminDestination(_ destination: HomeDestination) -> Bool {
        guard case .tile(let tile) = destination else { return false }

        return tile.requiresAdminAccess
    }
}

#Preview("Authenticated") {
    HomeView()
        .environment(SessionStore.previewAuthenticated)
        .preferredColorScheme(.dark)
}
#Preview("Unauthenticated") {
    HomeView()
        .environment(SessionStore.previewUnauthenticated)
        .preferredColorScheme(.dark)
}

#Preview("Admin") {
    HomeView()
        .environment(SessionStore.previewAdmin)
        .preferredColorScheme(.dark)
}
