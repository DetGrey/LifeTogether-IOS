//
//  AddButton.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 12/06/2026.
//

import SwiftUI

struct AddButton: View {
    let onClick: () -> Void
    
    var body: some View {
        Button(action: {
            onClick()
        }) {
            Image(systemName: "plus")
                .font(.appHeadlineMedium)
                .bold()
                .frame(width: 60, height: 60)
                .foregroundStyle(.textOnBrandTertiary)
                .background(.brandTertiary, in: Circle())
        }
    }
}

#Preview {
    AddButton {
        
    }
    .preferredColorScheme(.dark)
}
