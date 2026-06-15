//
//  ProfileDetails.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 12/06/2026.
//

import SwiftUI

struct ProfileDetails: View {
    let icon: String
    let title: String
    let value: String
    var enabled = true
    var imageUrl: String?
    var onClick: (() -> Void)?

    private var clickable: Bool {
        enabled && onClick != nil
    }

    var body: some View {
        Button {
            onClick?()
        } label: {
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                
                HStack(spacing: 0) {
                    leadingIconBox
                        .frame(width: totalWidth * 0.12)
                    
                    Text(title)
                        .font(.appBodyMedium)
                        .foregroundStyle(.textPrimary)
                        .padding(.leading, AppSpacing.large)
                        .frame(width: totalWidth * 0.40, alignment: .leading)
                    
                    HStack(spacing: AppSpacing.xSmall) {
                        Spacer()
                        
                        Text(value)
                            .font(.appBodyMedium)
                            .foregroundStyle(.textPrimary)
                        
                        if clickable {
                            Text(">")
                                .font(.appBodyMedium)
                                .foregroundStyle(.brandSecondary)
                        } else if !enabled {
                            Text(">")
                                .font(.appBodyMedium)
                                .foregroundStyle(.textPrimary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.trailing, AppSpacing.large)
                }
                .frame(width: totalWidth, height: geometry.size.height)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.large))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    @ViewBuilder
    private var leadingIconBox: some View {
        Group {
            if let imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image("ic_profile")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(AppSpacing.small)
                        .foregroundStyle(.textOnBrandSecondary)
                }
            } else {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(AppSpacing.small)
                    .foregroundStyle(.textOnBrandSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.brandSecondary)
        .clipped()
    }
}

#Preview {
    VStack(spacing: 16) {
        ProfileDetails(
            icon: "ic_profile",
            title: "Username",
            value: "Alex",
            imageUrl: nil,
            onClick: {}
        )

        ProfileDetails(
            icon: "ic_email",
            title: "Email",
            value: "alex@example.com",
            imageUrl: nil
        )

        ProfileDetails(
            icon: "ic_asterisk",
            title: "Family ID",
            value: "family-123",
            enabled: false,
            onClick: nil
        )
    }
    .padding()
    .background(.appBackground)
}
