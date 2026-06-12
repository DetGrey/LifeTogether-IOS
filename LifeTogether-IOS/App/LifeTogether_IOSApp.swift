//
//  LifeTogether_IOSApp.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import SwiftUI
import UIKit

@main
struct LifeTogether_IOSApp: App {
    init() {
        let backgroundColor = UIColor(named: "appBackground") ?? UIColor(red: 0.071, green: 0.055, blue: 0.082, alpha: 1)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().backgroundColor = backgroundColor
        UINavigationBar.appearance().barTintColor = backgroundColor
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                HomeView()
            }
            .preferredColorScheme(.dark)
        }
    }
}
