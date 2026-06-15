//
//  AdminGroceryCategoriesView.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 15/06/2026.
//

import SwiftUI

struct AdminGroceryCategoriesView: View {
    @Environment(SessionStore.self) private var sessionStore
    @State private var viewModel: AdminGroceryCategoriesViewModel

    let onAccessDenied: () -> Void

    init(
        onAccessDenied: @escaping () -> Void,
        viewModel: AdminGroceryCategoriesViewModel? = nil
    ) {
        self.onAccessDenied = onAccessDenied
        _viewModel = State(initialValue: viewModel ?? AdminGroceryCategoriesViewModel())
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.large) {
                Text("Add new category as a string with an emoji and a name with whitespace between e.g. \"🍞 Bakery\"")
                    .font(.appBodyMedium)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xSmall)

                Text("Grocery categories")
                    .font(.appLabelMedium)
                    .foregroundStyle(.textPrimary)

                if !viewModel.categories.isEmpty {
                    EditableListContainer(
                        items: viewModel.categories,
                        title: { "\($0.emoji) \($0.name)" },
                        canDelete: { viewModel.canDelete($0) },
                        onDelete: { viewModel.selectCategoryForDelete($0) }
                    )
                }
            }
            .padding(AppSpacing.medium)
            .padding(.bottom, AppSpacing.medium)
        }
        .scrollIndicators(.hidden)
        .background(.appBackground)
        .appNavigationTitle("Edit grocery list")
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: AppSpacing.small) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.appBodySmall)
                        .foregroundStyle(.statusError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                addCategoryBar
            }
            .padding(AppSpacing.medium)
            .background(.appBackground)
        }
        .alert(
            "Delete category?",
            isPresented: Binding(
                get: { viewModel.selectedCategory != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissDeleteCategory()
                    }
                }
            )
        ) {
            Button("Cancel", role: .cancel) {
                viewModel.dismissDeleteCategory()
            }
            Button("Delete", role: .destructive) {
                viewModel.confirmDeleteCategory()
            }
        } message: {
            if let selectedCategory = viewModel.selectedCategory {
                Text("Are you sure you want to delete the category: \(selectedCategory.emoji) \(selectedCategory.name)?")
            }
        }
        .onAppear {
            guard sessionStore.isAdmin else {
                onAccessDenied()
                return
            }
        }
        .onChange(of: sessionStore.isAdmin) { _, isAdmin in
            if !isAdmin {
                onAccessDenied()
            }
        }
    }

    private var addCategoryBar: some View {
        HStack(spacing: AppSpacing.small) {
            TextField(
                "Add category",
                text: $viewModel.newCategory,
                prompt: Text("Add category")
                    .foregroundStyle(.textSecondary)
            )
            .font(.appBodyMedium)
            .foregroundStyle(.textPrimary)
            .textInputAutocapitalization(.sentences)
            .submitLabel(.done)
            .onSubmit {
                viewModel.addCategory()
            }
            .padding(.horizontal, AppSpacing.medium)
            .frame(height: AppSizing.touchTargetMinimum)

            Button {
                viewModel.addCategory()
            } label: {
                HStack(spacing: AppSpacing.small) {
                    Text("Add")
                        .font(.appBodyMedium)
                    Image("ic_expand")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: AppSizing.iconSmall, height: AppSizing.iconSmall)
                }
                .foregroundStyle(viewModel.canAddCategory ? .brandSecondary : .textSecondary)
            }
            .disabled(!viewModel.canAddCategory)
            .padding(.trailing, AppSpacing.medium)
        }
        .frame(height: 60)
        .background(.appBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large))
    }
}

#Preview {
    NavigationStack {
        AdminGroceryCategoriesView(
            onAccessDenied: {},
            viewModel: AdminGroceryCategoriesViewModel(
                initialCategories: [
                    GroceryCategory(emoji: "🥦", name: "Vegetables"),
                    GroceryCategory(emoji: "🍞", name: "Bakery")
                ],
                observesCategories: false
            )
        )
            .environment(SessionStore.previewAdmin)
    }
    .preferredColorScheme(.dark)
}
