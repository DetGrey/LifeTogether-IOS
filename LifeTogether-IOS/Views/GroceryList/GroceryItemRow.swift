//
//  GroceryItemRow.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//


import SwiftUI

struct GroceryItemRow: View {
    let item: GroceryItem
    let trailingText: String?
    let onToggleCompleted: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.medium - AppSpacing.xSmall) {
            Button(action: onToggleCompleted) {
                Group {
                    if item.completed {
                        Image("ic_checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .frame(width: AppSizing.iconLarge, height: AppSizing.iconLarge)
                .foregroundStyle(.brandPrimary)
            }
            .buttonStyle(.plain)

            Text(item.itemName)
                .font(.appBodyLarge)
                .foregroundStyle(.textPrimary)
                .strikethrough(item.completed)
                .lineLimit(1)

            Spacer()

            if let trailingText {
                Text(trailingText)
                    .font(.appBodyLarge)
                    .foregroundStyle(.textPrimary)
                    .strikethrough(item.completed)
            }
        }
        .padding(.vertical, AppSpacing.small + AppSpacing.xSmall / 2)
    }
}

#Preview {
    VStack(spacing: 0) {
        GroceryItemRow(
            item: GroceryItem(
                itemName: "Bananas",
                category: GroceryCategory(emoji: "🍎", name: "Fruits"),
                approxPrice: 12
            ),
            trailingText: "~12kr.",
            onToggleCompleted: {}
        )

        GroceryItemRow(
            item: GroceryItem(
                itemName: "Potatoes",
                category: GroceryCategory(emoji: "🥦", name: "Vegetables"),
                completed: true
            ),
            trailingText: Date().abbreviatedDateString(),
            onToggleCompleted: {}
        )
    }
    .padding()
    .background(.appBackground)
}
