//
//  GroceryCategorySection.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//


import SwiftUI

struct GroceryCategorySection: View {
    let category: GroceryCategory
    let items: [GroceryItem]
    let isExpanded: Bool
    let onToggleSection: () -> Void
    let onToggleItem: (GroceryItem) -> Void

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            GrocerySectionHeader(
                emoji: category.emoji,
                title: category.name,
                isExpanded: isExpanded,
                showsDelete: false,
                onToggle: onToggleSection,
                onDelete: nil
            )

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        GroceryItemRow(
                            item: item,
                            trailingText: item.approxPrice?.groceryPriceString(),
                            onToggleCompleted: {
                                onToggleItem(item)
                            }
                        )
                    }
                }
            }
        }
    }
}

struct CompletedGrocerySection: View {
    let items: [GroceryItem]
    let isExpanded: Bool
    let onToggleSection: () -> Void
    let onDelete: () -> Void
    let onToggleItem: (GroceryItem) -> Void

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            GrocerySectionHeader(
                emoji: "✔️",
                title: "Bought",
                isExpanded: isExpanded,
                showsDelete: true,
                onToggle: onToggleSection,
                onDelete: onDelete
            )

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        GroceryItemRow(
                            item: item,
                            trailingText: item.lastUpdated.abbreviatedDateString(),
                            onToggleCompleted: {
                                onToggleItem(item)
                            }
                        )
                    }
                }
            }
        }
    }
}

private struct GrocerySectionHeader: View {
    let emoji: String
    let title: String
    let isExpanded: Bool
    let showsDelete: Bool
    let onToggle: () -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: AppSpacing.small) {
                HStack(alignment: .bottom) {
                    Text(emoji)
                        .font(.appBodyLarge)

                    Text(title)
                        .font(.appLabelLarge)
                        .foregroundStyle(.brandTertiary)

                    Spacer()

                    if showsDelete, let onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: AppSizing.iconMedium))
                                .frame(width: AppSizing.iconMedium, height: AppSizing.iconMedium)
                                .foregroundStyle(.statusError)
                        }
                        .buttonStyle(.plain)
                    }

                    Image(systemName: isExpanded ? "chevron.right" : "chevron.down")
                        .font(.system(size: AppSizing.iconMedium))
                        .frame(width: AppSizing.iconMedium, height: AppSizing.iconMedium)
                        .foregroundStyle(.brandTertiary)
                }

                Rectangle()
                    .fill(.borderSecondary)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview("Category section") {
    let category = GroceryCategory(emoji: "🍎", name: "Fruits")
    let items = [
        GroceryItem(itemName: "Bananas", category: category, approxPrice: 12),
        GroceryItem(itemName: "Apples", category: category, approxPrice: 18)
    ]

    GroceryCategorySection(
        category: category,
        items: items,
        isExpanded: true,
        onToggleSection: {},
        onToggleItem: { _ in }
    )
    .padding()
    .background(.appBackground)
}

#Preview("Section header") {
    GrocerySectionHeader(
        emoji: "🥛",
        title: "Dairy",
        isExpanded: true,
        showsDelete: false,
        onToggle: {},
        onDelete: nil
    )
    .padding()
    .background(.appBackground)
}

#Preview("Completed section") {
    CompletedGrocerySection(
        items: [
            GroceryItem(
                itemName: "Potatoes",
                category: GroceryCategory(emoji: "🥦", name: "Vegetables"),
                completed: true
            ),
            GroceryItem(
                itemName: "Dish soap",
                category: GroceryCategory(emoji: "🧼", name: "Household"),
                completed: true
            )
        ],
        isExpanded: true,
        onToggleSection: {},
        onDelete: {},
        onToggleItem: { _ in }
    )
    .padding()
    .background(.appBackground)
}
