//
//  AddGroceryItemBar.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//


import SwiftUI

private enum FocusedField { case name, price }

struct AddGroceryItemBar: View {
    @Bindable var viewModel: GroceryListViewModel
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack(spacing: 0) {
            TextField(
                "Add item...",
                text: $viewModel.newItemName,
                prompt: Text("Add item...")
                    .foregroundStyle(.textSecondary)
            )
                .font(.appBodyMedium)
                .foregroundStyle(.textPrimary)
                .textInputAutocapitalization(.sentences)
                .focused($focusedField, equals: .name)
                .padding(AppSpacing.medium)

            HStack(spacing: AppSpacing.medium - AppSpacing.xSmall) {
                Menu {
                    ForEach(viewModel.groceryCategories) { category in
                        Button {
                            viewModel.selectedCategory = category
                        } label: {
                            Text("\(category.emoji) \(category.name)")
                        }
                    }
                } label: {
                    Text(viewModel.selectedCategory.emoji)
                        .frame(width: AppSizing.touchTargetMinimum, height: AppSizing.touchTargetMinimum)
                        .overlay(
                            Circle()
                                .stroke(.textPrimary, lineWidth: 2)
                        )
                }

                TextField(
                    "Price",
                    text: $viewModel.newItemPrice,
                    prompt: Text("Price")
                        .foregroundStyle(.textSecondary)
                )
                    .font(.appBodySmall)
                    .foregroundStyle(.textPrimary)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
                    .padding(.horizontal, AppSpacing.medium - AppSpacing.xSmall)
                    .frame(height: AppSizing.touchTargetMinimum)
                    .background(.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.small))

                Button {
                    viewModel.addItem()
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Text("Add")
                            .font(.appBodyMedium)
                        Image("ic_expand")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: AppSizing.iconSmall, height: AppSizing.iconSmall)
                    }
                    .font(.appBodyMedium)
                    .foregroundStyle(viewModel.canAddItem ? .brandSecondary : .textSecondary)
                }
                .disabled(!viewModel.canAddItem)
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.bottom, 14)
        }
        .background(.appBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                suggestionToolbar
            }
        }
    }

    @ViewBuilder
    private var suggestionToolbar: some View {
        if focusedField == .name && !viewModel.currentSuggestions.isEmpty {
            suggestionChips(for: viewModel.currentSuggestions)
        }
    }

    private func suggestionChips(for suggestions: [GrocerySuggestion]) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: AppSpacing.small) {
                ForEach(suggestions) { suggestion in
                    Button {
                        viewModel.applySuggestion(suggestion)
                    } label: {
                        Text("\(suggestion.category.emoji) \(suggestion.suggestionName)")
                            .font(.appBodyMedium)
                            .foregroundStyle(.textPrimary)
                            .padding(.horizontal, AppSpacing.medium)
                            .padding(.vertical, AppSpacing.small)
                            .background(.brandPrimaryContainer, in: Capsule())
                    }
                }
            }
            .padding(.horizontal, AppSpacing.medium)
        }
        .scrollIndicators(.hidden)
    }
}

private let previewSuggestions: [GrocerySuggestion] = [
    GrocerySuggestion(id: "1", suggestionName: "Milk", category: GroceryCategory(emoji: "🥛", name: "Dairy"), approxPrice: 15),
    GrocerySuggestion(id: "2", suggestionName: "Miso paste", category: GroceryCategory(emoji: "❓️", name: "Uncategorized"), approxPrice: nil),
]

#Preview("Empty") {
    AddGroceryItemBar(viewModel: GroceryListViewModel())
        .padding()
        .background(.appBackground)
}

#Preview("Filled") {
    AddGroceryItemBar(
        viewModel: {
            let viewModel = GroceryListViewModel()
            viewModel.newItemName = "Oat milk"
            viewModel.newItemPrice = "18"
            viewModel.selectedCategory = GroceryCategory(emoji: "🥛", name: "Dairy")
            return viewModel
        }()
    )
    .padding()
    .background(.appBackground)
}

#Preview("Suggestions") {
    let chips = searchGrocerySuggestions(query: "Mi", suggestions: previewSuggestions)

    VStack(spacing: 0) {
        AddGroceryItemBar(viewModel: {
            let vm = GroceryListViewModel(initialSuggestions: previewSuggestions)
            vm.newItemName = "Mi"
            return vm
        }())
        .padding(.horizontal, AppSpacing.medium)
        .padding(.top, AppSpacing.medium)

        ScrollView(.horizontal) {
            HStack(spacing: AppSpacing.small) {
                ForEach(chips) { suggestion in
                    Text("\(suggestion.category.emoji) \(suggestion.suggestionName)")
                        .font(.appBodyMedium)
                        .foregroundStyle(.textPrimary)
                        .padding(.horizontal, AppSpacing.medium)
                        .padding(.vertical, AppSpacing.small)
                        .background(.brandPrimaryContainer, in: Capsule())
                }
            }
            .padding(.horizontal, AppSpacing.medium)
        }
        .scrollIndicators(.hidden)
        .padding(.top, AppSpacing.small)
    }
    .background(.appBackground)
}
