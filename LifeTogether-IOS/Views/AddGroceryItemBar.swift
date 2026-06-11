//
//  AddGroceryItemBar.swift
//  LifeTogether-IOS
//
//  Created by Ane Novrup Larsen on 11/06/2026.
//


import SwiftUI

struct AddGroceryItemBar: View {
    @Bindable var viewModel: GroceryListViewModel

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
                        Image(systemName: "chevron.right")
                            .font(.system(size: AppSizing.iconSmall, weight: .semibold))
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
    }
}

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
