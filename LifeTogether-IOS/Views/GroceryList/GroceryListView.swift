//
//  GroceryListView.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//


import SwiftUI

struct GroceryListView: View {
    @State private var viewModel = GroceryListViewModel()
    @State private var showingDeleteCompletedAlert = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.medium) {
                if let expectedTotalPrice = viewModel.expectedTotalPrice {
                    VStack(spacing: AppSpacing.xSmall) {
                        Text("Expected total price:")
                        Text(expectedTotalPrice.groceryPriceString(precise: true))
                    }
                    .font(.appTitleMedium)
                    .foregroundStyle(.brandSecondary)
                }

                ForEach(viewModel.activeItemsByCategory, id: \.category.id) { section in
                    GroceryCategorySection(
                        category: section.category,
                        items: section.items,
                        isExpanded: viewModel.expandedCategories.contains(section.category.name),
                        onToggleSection: {
                            viewModel.toggleCategory(section.category)
                        },
                        onToggleItem: { item in
                            viewModel.toggleCompleted(item)
                        }
                    )
                }

                if !viewModel.completedItems.isEmpty {
                    CompletedGrocerySection(
                        items: viewModel.completedItems,
                        isExpanded: viewModel.isCompletedSectionExpanded,
                        onToggleSection: {
                            viewModel.toggleCompletedSection()
                        },
                        onDelete: {
                            showingDeleteCompletedAlert = true
                        },
                        onToggleItem: { item in
                            viewModel.toggleCompleted(item)
                        }
                    )
                }

                if viewModel.items.isEmpty {
                    Text("No items on the list yet")
                        .font(.appBodyMedium)
                        .foregroundStyle(.textSecondary)
                        .padding(.top, AppSpacing.xxLarge)
                }
            }
            .padding(AppSpacing.medium)
            .padding(.bottom, AppSpacing.medium)
        }
        .background(.appBackground)
        .appNavigationTitle("Grocery list")
        .safeAreaInset(edge: .bottom) {
            AddGroceryItemBar(viewModel: viewModel)
                .padding(AppSpacing.medium)
                .background(.appBackground)
        }
        .alert("Delete completed items", isPresented: $showingDeleteCompletedAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteCompletedItems()
            }
        } message: {
            Text("Are you sure you want to delete all completed grocery items?")
        }
    }
}

#Preview {
    NavigationStack {
        GroceryListView()
    }
    .preferredColorScheme(.dark)
}
