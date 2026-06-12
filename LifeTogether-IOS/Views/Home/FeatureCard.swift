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
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack {
                Spacer()
                Image(systemName: icon)
                    .resizable() // Tells SwiftUI this vector icon is allowed to stretch/scale
                    .aspectRatio(contentMode: .fit) // Scales it up as large as possible without distortion
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.brandTertiary)
                
                Text(title)
                    .font(.appTitleMedium)
                    .foregroundStyle(.textPrimary)
                Spacer()
            }
            .padding(AppSpacing.small)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(.brandPrimaryContainer, in: RoundedRectangle(cornerRadius: AppRadius.large))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let tile = HomeTile.groceryList
    FeatureCard(
        title: tile.rawValue,
        icon: tile.iconName,
        onClick: {}
    )
}
