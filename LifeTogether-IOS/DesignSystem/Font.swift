//
//  Font.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//
import SwiftUI

extension Font {
    // Properties map directly to your tokens
    static var appDisplayLarge: Font { AppTypography.displayLarge }
    static var appDisplayMedium: Font { AppTypography.displayMedium }
    static var appDisplaySmall: Font { AppTypography.displaySmall }

    static var appHeadlineLarge: Font { AppTypography.headlineLarge }
    static var appHeadlineMedium: Font { AppTypography.headlineMedium }
    static var appHeadlineSmall: Font { AppTypography.headlineSmall }

    static var appTitleLarge: Font { AppTypography.titleLarge }
    static var appTitleMedium: Font { AppTypography.titleMedium }
    static var appTitleSmall: Font { AppTypography.titleSmall }

    static var appBodyLarge: Font { AppTypography.bodyLarge }
    static var appBodyMedium: Font { AppTypography.bodyMedium }
    static var appBodySmall: Font { AppTypography.bodySmall }

    static var appLabelLarge: Font { AppTypography.labelLarge }
    static var appLabelMedium: Font { AppTypography.labelMedium }
    static var appLabelSmall: Font { AppTypography.labelSmall }
    
    // Functions handle your dynamic on-the-fly resizing requests
    static func appBody(size: CGFloat) -> Font { AppTypography.body(size: size) }
    static func appDisplay(size: CGFloat) -> Font { AppTypography.display(size: size) }
    static func appLabel(size: CGFloat) -> Font { AppTypography.label(size: size) }
}
