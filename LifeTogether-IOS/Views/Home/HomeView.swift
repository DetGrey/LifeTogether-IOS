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
        guard tile != .groceryList || sessionStore.isLoggedIn else { return }

        navigationPath.append(.tile(tile))
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
