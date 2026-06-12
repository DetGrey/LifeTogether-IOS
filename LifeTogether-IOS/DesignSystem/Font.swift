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

struct AppTypography {
    // MARK: - Display
    static let displayLarge  = Font.custom("MontserratAlternates-Regular", size: 36, relativeTo: .largeTitle)
    static let displayMedium = Font.custom("MontserratAlternates-Regular", size: 32, relativeTo: .largeTitle)
    static let displaySmall  = Font.custom("MontserratAlternates-Regular", size: 28, relativeTo: .title)
    
    // MARK: - Headline
    static let headlineLarge  = Font.custom("MontserratAlternates-Regular", size: 30, relativeTo: .title)
    static let headlineMedium = Font.custom("MontserratAlternates-Regular", size: 26, relativeTo: .title2)
    static let headlineSmall  = Font.custom("MontserratAlternates-Regular", size: 24, relativeTo: .title3)
    
    // MARK: - Title
    static let titleLarge  = Font.custom("MontserratAlternates-Regular", size: 22, relativeTo: .headline)
    static let titleMedium = Font.custom("MontserratAlternates-Regular", size: 20, relativeTo: .subheadline)
    static let titleSmall  = Font.custom("MontserratAlternates-Regular", size: 18, relativeTo: .subheadline)
    
    // MARK: - Body (Lato Regular)
    static let bodyLarge  = Font.custom("Lato-Regular", size: 20, relativeTo: .body)
    static let bodyMedium = Font.custom("Lato-Regular", size: 16, relativeTo: .body)
    static let bodySmall  = Font.custom("Lato-Regular", size: 14, relativeTo: .subheadline)
    
    // MARK: - Label (Lato Italic)
    static let labelLarge  = Font.custom("Lato-Italic", size: 20, relativeTo: .caption)
    static let labelMedium = Font.custom("Lato-Italic", size: 16, relativeTo: .caption)
    static let labelSmall  = Font.custom("Lato-Italic", size: 12, relativeTo: .caption2)
    
    // MARK: - Dynamic Modifiers (For Quick Font Size Overrides)
    static func display(size: CGFloat) -> Font {
        .custom("MontserratAlternates-Regular", size: size, relativeTo: .largeTitle)
    }
    
    static func body(size: CGFloat) -> Font {
        .custom("Lato-Regular", size: size, relativeTo: .body)
    }
    
    static func label(size: CGFloat) -> Font {
        .custom("Lato-Italic", size: size, relativeTo: .caption)
    }
}
