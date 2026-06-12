//
//  HomeView.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import SwiftUI

struct HomeView: View {
    @State private var navigationPath: [HomeTile] = []
    
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
                                            navigationPath.append(tile)
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
            .navigationDestination(for: HomeTile.self) { tile in
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

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
