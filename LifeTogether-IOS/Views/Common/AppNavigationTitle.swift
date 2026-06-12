//
//  AppNavigationTitle.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import SwiftUI

private struct AppNavigationTitleModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.appBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.appDisplayMedium)
                        .foregroundStyle(.brandPrimary)
                        .lineLimit(1)
                }
            }
    }
}

extension View {
    func appNavigationTitle(_ title: String) -> some View {
        modifier(AppNavigationTitleModifier(title: title))
    }
}
