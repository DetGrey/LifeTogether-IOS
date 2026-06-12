//
//  HomeView.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(AuthSession.self) private var authSession
    @State private var navigationPath: [HomeDestination] = []
    
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
                    
                    VStack {
//                        Text("Family image")
//                            .font(.appHeadlineSmall)
//                            .foregroundStyle(.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(.surfaceSecondary, in: RoundedRectangle(cornerRadius: AppRadius.large))
                    
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
            .padding(AppSpacing.medium)
            .background(.appBackground)
            .appNavigationTitle("LifeTogether")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        navigationPath.append(authSession.isLoggedIn ? .profile : .login)
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: AppSizing.iconMedium))
                            .foregroundStyle(.brandPrimary)
                    }
                    .accessibilityLabel(authSession.isLoggedIn ? "Profile" : "Login")
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
        }
    }

    private func navigate(to tile: HomeTile) {
        guard tile != .groceryList || authSession.isLoggedIn else { return }

        navigationPath.append(.tile(tile))
    }
}

#Preview {
    HomeView()
        .environment(AuthSession())
        .preferredColorScheme(.dark)
}
