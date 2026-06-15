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
    case userLists   = "Lists"
    case mealPlanner = "Meal Planner"
    case traveller   = "Traveller"
    case adminGroceryCategories = "Grocery categories"
    case adminGrocerySuggestions = "Grocery suggestions"
    
    // Conforming to Identifiable makes looping in SwiftUI seamless
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .groceryList:            return "ic_grocery"
        case .recipes:                return "ic_recipe"
        case .guides:                 return "ic_guide"
        case .gallery:                return "ic_gallery"
        case .tipTracker:             return "ic_tip"
        case .userLists:              return "ic_list"
        case .mealPlanner:            return "ic_meal_plan"
        case .traveller:              return "map.fill"
        case .adminGroceryCategories: return "ic_grocery"
        case .adminGrocerySuggestions: return "ic_add_grocery"
        }
    }

    var isSystemIcon: Bool { self == .traveller }

    var requiresLogin: Bool {
        switch self {
        case .groceryList, .adminGroceryCategories, .adminGrocerySuggestions:
            return true
        case .recipes, .guides, .gallery, .tipTracker, .userLists, .mealPlanner, .traveller:
            return false
        }
    }

    var requiresAdminAccess: Bool {
        switch self {
        case .adminGroceryCategories, .adminGrocerySuggestions:
            return true
        case .groceryList, .recipes, .guides, .gallery, .tipTracker, .userLists, .mealPlanner, .traveller:
            return false
        }
    }
}

struct HomeTileRow: Identifiable {
    let id = UUID() // Unique ID so SwiftUI can track this specific row layout
    let tiles: [HomeTile]
}
