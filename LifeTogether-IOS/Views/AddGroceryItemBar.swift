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
            TextField("Add item...", text: $viewModel.newItemName)
                .font(.appBodyMedium)
                .foregroundStyle(.textPrimary)
                .textInputAutocapitalization(.sentences)
                .padding(16)

            HStack(spacing: 12) {
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
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(.textPrimary, lineWidth: 2)
                        )
                }

                TextField("Price", text: $viewModel.newItemPrice)
                    .font(.appBodySmall)
                    .foregroundStyle(.textPrimary)
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Button {
                    viewModel.addItem()
                } label: {
                    HStack(spacing: 4) {
                        Text("Add")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .font(.appBodyMedium)
                    .foregroundStyle(viewModel.canAddItem ? .brandSecondary : .textSecondary)
                }
                .disabled(!viewModel.canAddItem)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(.appBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
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
