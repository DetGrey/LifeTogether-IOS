//
//  Formatters.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//

import Foundation

extension Float {
    func groceryPriceString(precise: Bool = false) -> String {
        let format = precise ? "%.2f" : "%.0f"
        return "~" + String(format: format, locale: Locale(identifier: "en_US"), self) + "kr."
    }
}

extension Date {
    func abbreviatedDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "dd. MMM yyyy"
        return formatter.string(from: self)
    }
}
