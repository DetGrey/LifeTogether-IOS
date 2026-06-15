//
//  GrocerySectionHeader.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 15/06/2026.
//

import SwiftUI

struct GrocerySectionHeader: View {
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
                            Image("ic_delete")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: AppSizing.iconMedium, height: AppSizing.iconMedium)
                                .foregroundStyle(.statusError)
                        }
                        .buttonStyle(.plain)
                    }

                    Image(isExpanded ? "ic_expanded" : "ic_expand")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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

#Preview {
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
    .preferredColorScheme(.dark)
}
