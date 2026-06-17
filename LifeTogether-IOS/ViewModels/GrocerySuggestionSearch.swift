//
//  GrocerySuggestionSearch.swift
//  LifeTogether-IOS
//

import Foundation

private let defaultMinQueryLength = 2
private let defaultLimit = 10

func searchGrocerySuggestions(
    query: String,
    suggestions: [GrocerySuggestion],
    limit: Int = defaultLimit,
    minQueryLength: Int = defaultMinQueryLength
) -> [GrocerySuggestion] {
    let normalizedQuery = normalizeSearchText(query)
    guard normalizedQuery.count >= minQueryLength else { return [] }

    return suggestions
        .compactMap { suggestion -> (GrocerySuggestion, Int)? in
            let score = scoreSuggestion(normalizedQuery, suggestion: suggestion)
            return score > 0 ? (suggestion, score) : nil
        }
        .sorted { lhs, rhs in
            if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
            if lhs.0.suggestionName.count != rhs.0.suggestionName.count {
                return lhs.0.suggestionName.count < rhs.0.suggestionName.count
            }
            return lhs.0.suggestionName.lowercased() < rhs.0.suggestionName.lowercased()
        }
        .prefix(limit)
        .map(\.0)
}

private func scoreSuggestion(_ normalizedQuery: String, suggestion: GrocerySuggestion) -> Int {
    let normalizedName = normalizeSearchText(suggestion.suggestionName)
    let normalizedCategory = normalizeSearchText(suggestion.category.name)
    let nameTokens = normalizedName.split(separator: " ").filter { !$0.isEmpty }.map(String.init)
    let categoryTokens = normalizedCategory.split(separator: " ").filter { !$0.isEmpty }.map(String.init)

    if normalizedName == normalizedQuery { return 100 }
    if normalizedName.hasPrefix(normalizedQuery) { return 90 }
    if nameTokens.contains(where: { $0.hasPrefix(normalizedQuery) }) { return 80 }
    if normalizedCategory.hasPrefix(normalizedQuery) { return 70 }
    if categoryTokens.contains(where: { $0.hasPrefix(normalizedQuery) }) { return 65 }
    if normalizedName.contains(normalizedQuery) { return 60 }
    if normalizedCategory.contains(normalizedQuery) { return 50 }
    return 0
}

private func normalizeSearchText(_ value: String) -> String {
    value
        .trimmingCharacters(in: .whitespaces)
        .lowercased()
        .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
}
