//
//  ExampleView.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import SwiftUI

struct ExampleView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.brandPrimary)
            Text("Hello, world!").foregroundStyle(.brandPrimary)
        }
        .padding()
    }
}

#Preview {
    ExampleView()
}
