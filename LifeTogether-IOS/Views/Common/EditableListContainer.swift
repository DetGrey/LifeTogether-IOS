//
//  EditableListContainer.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 15/06/2026.
//

import SwiftUI

struct EditableListContainer<Item: Identifiable>: View {
    let items: [Item]
    let title: (Item) -> String
    var canDelete: (Item) -> Bool = { _ in true }
    let onDelete: (Item) -> Void

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            Divider()
                .frame(height: 2)
                .overlay(.brandPrimary)

            ForEach(items) { item in
                HStack {
                    Text(title(item))
                        .font(.appBodyLarge)
                        .foregroundStyle(.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    if canDelete(item) {
                        Button {
                            onDelete(item)
                        } label: {
                            Image("ic_delete")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: AppSizing.iconMedium, height: AppSizing.iconMedium)
                                .foregroundStyle(.statusError)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: AppSizing.touchTargetMinimum)

                Divider()
                    .frame(height: 2)
                    .overlay(.brandPrimary)
            }
        }
        .padding(AppSpacing.small)
    }
}

#Preview {
    EditableListContainer(
        items: [
            GroceryCategory(emoji: "🍎", name: "Fruits and vegetables"),
            GroceryCategory(emoji: "🍞", name: "Bakery"),
            GroceryCategory(emoji: "❄️", name: "Frozen food")
        ],
        title: { "\($0.emoji) \($0.name)" },
        onDelete: { _ in }
    )
    .preferredColorScheme(.dark)
}
