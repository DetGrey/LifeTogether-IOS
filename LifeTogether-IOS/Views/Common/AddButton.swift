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
            Image("ic_plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundStyle(.textOnBrandTertiary)
                .frame(width: 60, height: 60)
                .background(.brandTertiary, in: Circle())
        }
    }
}

#Preview {
    AddButton {
        
    }
    .preferredColorScheme(.dark)
}
