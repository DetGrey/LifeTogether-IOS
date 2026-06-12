//
//  ProfileView.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(SessionStore.self) private var sessionStore
    @State private var showingLogoutAlert = false

    var body: some View {
        if let user = sessionStore.currentUser {
            ScrollView {
                LazyVStack(
                    alignment: HorizontalAlignment.leading,
                    spacing: AppSpacing.xLarge
                ) {
                    VStack(alignment: HorizontalAlignment.center) {
                        Group {
                            if let urlString = user.imageUrl, let validURL = URL(string: urlString) {
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
                        
                        Text(user.name)
                            .padding(.top, AppSpacing.small)
                            .font(.appHeadlineLarge)
                            .foregroundStyle(.brandPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: AppSpacing.medium) {
                        Text("Personal details")
                            .font(.appHeadlineMedium)
                            .foregroundStyle(.brandSecondary)
                        
                        ProfileDetails(
                            systemImage: "person.fill",
                            title: "Name",
                            value: user.name,
                            onClick: {
                            }
                        )

                        ProfileDetails(
                            systemImage: "envelope.fill",
                            title: "Email",
                            value: user.email
                        )

                        if let birthday = user.birthday {
                            ProfileDetails(
                                systemImage: "calendar",
                                title: "Birthday",
                                value: birthday.fullMonthDateString()
                            )
                        }

                        ProfileDetails(
                            systemImage: "lock.fill",
                            title: "Password",
                            value: "Change password",
                            enabled: false
                        )
                    
                        ProfileDetails(
                            systemImage: "rectangle.portrait.and.arrow.right",
                            title: "Logout",
                            value: "",
                            onClick: {
                                showingLogoutAlert = true
                            }
                        )
                    }
                    
                }
            }
            .scrollIndicators(.hidden)
            .padding(AppSpacing.small)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.appBackground)
            .appNavigationTitle("Profile")
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Logout", role: .destructive) {
                    do {
                        try sessionStore.signOut()
                    } catch {
                        sessionStore.lastErrorMessage = error.localizedDescription
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(SessionStore.previewAuthenticated)
    }
    .preferredColorScheme(.dark)
}
