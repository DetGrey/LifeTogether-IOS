//
//  ProfileView.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(SessionStore.self) private var sessionStore

    var body: some View {
        let user = sessionStore.currentUser

        ScrollView {
            LazyVStack(
                alignment: HorizontalAlignment.center,
                spacing: AppSpacing.xLarge
            ) {
                VStack {
                    Group {
                        if let urlString = user?.imageUrl, let validURL = URL(string: urlString) {
                            AsyncImage(url: validURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.textPrimary)
                        }
                    }
                    .frame(width: 250, height: 250)
                    .background(.surfaceSecondary)
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        AddButton(onClick: {
                            
                        })
                        
                    }
                    .overlay {
                        Circle()
                            .frame(width: AppSizing.touchTargetMinimum, height: AppSizing.touchTargetMinimum)
                            .clipShape(Circle())
                    }
                    
                    if let name = user?.name {
                        Text(name)
                            .font(.appHeadlineLarge)
                            .foregroundStyle(.brandPrimary)
                    }
                }
                
                
            }
        }
        .padding(AppSpacing.small)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .appNavigationTitle("Profile")
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(SessionStore.previewAuthenticated)
    }
    .preferredColorScheme(.dark)
}
