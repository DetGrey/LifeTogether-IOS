//
//  AdminGrocerySuggestionsView.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 15/06/2026.
//

import SwiftUI

struct AdminGrocerySuggestionsView: View {
    @Environment(SessionStore.self) private var sessionStore
    @State private var viewModel: AdminGrocerySuggestionsViewModel

    let onAccessDenied: () -> Void

    init(
        onAccessDenied: @escaping () -> Void,
        viewModel: AdminGrocerySuggestionsViewModel? = nil
    ) {
        self.onAccessDenied = onAccessDenied
        _viewModel = State(initialValue: viewModel ?? AdminGrocerySuggestionsViewModel())
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.large) {
                Text("Add a new suggestion by choosing the category (emoji) and writing the suggestion name.")
                    .font(.appBodyMedium)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xSmall)

                Text("Grocery suggestions")
                    .font(.appLabelMedium)
                    .foregroundStyle(.textPrimary)

                VStack(spacing: AppSpacing.small) {
                    ForEach(viewModel.suggestionsByCategory, id: \.category.id) { section in
                        VStack(spacing: AppSpacing.small) {
                            GrocerySectionHeader(
                                emoji: section.category.emoji,
                                title: section.category.name,
                                isExpanded: viewModel.expandedCategories.contains(section.category.name),
                                showsDelete: false,
                                onToggle: {
                                    viewModel.toggleCategory(section.category)
                                },
                                onDelete: nil
                            )

                            if viewModel.expandedCategories.contains(section.category.name) {
                                VStack(spacing: 0) {
                                    ForEach(section.suggestions) { suggestion in
                                        GrocerySuggestionRow(
                                            suggestion: suggestion,
                                            onEdit: {
                                                viewModel.startEditing(suggestion)
                                            },
                                            onDelete: {
                                                viewModel.selectSuggestionForDelete(suggestion)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
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

                suggestionInputBar
            }
            .padding(AppSpacing.medium)
            .background(.appBackground)
        }
        .alert(
            "Delete suggestion?",
            isPresented: Binding(
                get: { viewModel.selectedSuggestion != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissDeleteSuggestion()
                    }
                }
            )
        ) {
            Button("Cancel", role: .cancel) {
                viewModel.dismissDeleteSuggestion()
            }
            Button("Delete", role: .destructive) {
                viewModel.confirmDeleteSuggestion()
            }
        } message: {
            if let selectedSuggestion = viewModel.selectedSuggestion {
                Text("Are you sure you want to delete: \"\(selectedSuggestion.category.emoji) \(selectedSuggestion.category.name) - \(selectedSuggestion.suggestionName)\"?")
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

    private var suggestionInputBar: some View {
        VStack(spacing: 0) {
            TextField(
                "Add suggestion...",
                text: $viewModel.newSuggestionText,
                prompt: Text("Add suggestion...")
                    .foregroundStyle(.textSecondary)
            )
            .font(.appBodyMedium)
            .foregroundStyle(.textPrimary)
            .textInputAutocapitalization(.sentences)
            .submitLabel(.done)
            .onSubmit {
                viewModel.saveSuggestion()
            }
            .padding(AppSpacing.medium)

            HStack(spacing: AppSpacing.medium - AppSpacing.xSmall) {
                Menu {
                    ForEach(viewModel.categories) { category in
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
                    text: $viewModel.newSuggestionPrice,
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
                    viewModel.saveSuggestion()
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Text(viewModel.isEditing ? "Save" : "Add")
                            .font(.appBodyMedium)
                        Image("ic_expand")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: AppSizing.iconSmall, height: AppSizing.iconSmall)
                    }
                    .foregroundStyle(viewModel.canSaveSuggestion ? .brandSecondary : .textSecondary)
                }
                .disabled(!viewModel.canSaveSuggestion)
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.bottom, 14)
        }
        .background(.appBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
    }
}

private struct GrocerySuggestionRow: View {
    let suggestion: GrocerySuggestion
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            Text(suggestion.suggestionName)
                .font(.appBodyMedium)
                .foregroundStyle(.textPrimary)
                .lineLimit(1)

            Spacer()

            if let approxPrice = suggestion.approxPrice {
                Text(approxPrice.groceryPriceString())
                    .font(.appBodyMedium)
                    .foregroundStyle(.textPrimary)
            }

            Button(action: onEdit) {
                Image("ic_edit")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: AppSizing.iconMedium, height: AppSizing.iconMedium)
                    .foregroundStyle(.textPrimary)
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image("ic_delete")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: AppSizing.iconMedium, height: AppSizing.iconMedium)
                    .foregroundStyle(.statusError)
            }
            .buttonStyle(.plain)
        }
        .frame(height: AppSizing.touchTargetMinimum)
        .padding(.leading, AppSpacing.medium)
    }
}

#Preview {
    let vegetables = GroceryCategory(emoji: "🥦", name: "Vegetables")
    NavigationStack {
        AdminGrocerySuggestionsView(
            onAccessDenied: {},
            viewModel: AdminGrocerySuggestionsViewModel(
                initialCategories: [vegetables],
                initialSuggestions: [
                    GrocerySuggestion(
                        suggestionName: "Broccoli",
                        category: vegetables,
                        approxPrice: 17.5
                    )
                ],
                observesData: false
            )
        )
        .environment(SessionStore.previewAdmin)
    }
    .preferredColorScheme(.dark)
}
