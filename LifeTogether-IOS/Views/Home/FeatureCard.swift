//
//  FeatureCard.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import SwiftUI

struct FeatureCard: View {
    let title: String
    let icon: String
    var isSystemIcon: Bool = false
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack {
                Spacer()
                iconImage
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.brandTertiary)
                
                Text(title)
                    .font(.appTitleMedium)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(AppSpacing.small)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(.brandPrimaryContainer, in: RoundedRectangle(cornerRadius: AppRadius.large))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var iconImage: some View {
        if isSystemIcon {
            Image(systemName: icon).resizable()
        } else {
            Image(icon).resizable()
        }
    }
}

#Preview {
    let tile = HomeTile.adminGroceryCategories
    FeatureCard(
        title: tile.rawValue,
        icon: tile.iconName,
        isSystemIcon: tile.isSystemIcon,
        onClick: {}
    )
    .frame(width: 200, height: 150)
}
