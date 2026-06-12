//
//  HomeTile.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//


import Foundation

enum HomeTile: String, CaseIterable, Identifiable {
    case groceryList = "Grocery List"
    case recipes     = "Recipes"
    case guides      = "Guides"
    case gallery     = "Gallery"
    case tipTracker  = "Tip Tracker"
    case lists       = "Lists"
    case mealPlanner = "Meal Planner"
    case traveller   = "Traveller"
    
    // Conforming to Identifiable makes looping in SwiftUI seamless
    var id: String { self.rawValue }
    
    // Centralized SF Symbols mapping for your feature icons
    var iconName: String {
        switch self {
        case .groceryList: return "cart.fill"
        case .recipes:     return "fork.knife"
        case .guides:      return "book.closed.fill"
        case .gallery:     return "photo.on.rectangle.angled"
        case .tipTracker:  return "dollarsign.circle.fill"
        case .lists:       return "checklist"
        case .mealPlanner: return "calendar.badge.plus"
        case .traveller:   return "map.fill"
        }
    }
}

struct HomeTileRow: Identifiable {
    let id = UUID() // Unique ID so SwiftUI can track this specific row layout
    let tiles: [HomeTile]
}
