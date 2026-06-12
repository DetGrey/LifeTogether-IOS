//
//  ProfileView.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        Text("Profile")
            .font(.appTitleLarge)
            .foregroundStyle(.textPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.appBackground)
            .appNavigationTitle("Profile")
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .preferredColorScheme(.dark)
}
