//
//  ToolbarIcon.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 16/06/2026.
//

import SwiftUI

struct ToolbarIcon: View {
    var icon: String
    
    var body: some View {
        Image(icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: AppSizing.iconLarge, height: AppSizing.iconLarge)
            .foregroundStyle(.textPrimary)
    }
}
