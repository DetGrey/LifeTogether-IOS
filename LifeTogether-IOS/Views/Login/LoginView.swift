//
//  LoginView.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 12/06/2026.
//

import SwiftUI

struct LoginView: View {
    @Environment(SessionStore.self) private var sessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoggingIn = false

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !isLoggingIn
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                TextField("Email", text: $email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(isLoggingIn)
                    .appTextFieldStyle()

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .disabled(isLoggingIn)
                    .appTextFieldStyle()

                Button(action: login) {
                    HStack(spacing: AppSpacing.small) {
                        if isLoggingIn {
                            ProgressView()
                                .tint(.textOnBrandPrimaryContainer)
                        }

                        Text("Login")
                            .font(.appTitleSmall)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: AppSizing.touchTargetMinimum)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.textOnBrandPrimaryContainer)
                .background(.brandPrimaryContainer, in: RoundedRectangle(cornerRadius: AppRadius.medium))
                .opacity(canSubmit ? 1 : 0.6)
                .disabled(!canSubmit)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.appBodySmall)
                        .foregroundStyle(.statusError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(AppSpacing.medium)
        }
        .background(.appBackground)
        .appNavigationTitle("Login")
    }

    private func login() {
        guard canSubmit else { return }

        errorMessage = nil
        isLoggingIn = true

        Task {
            do {
                try await sessionStore.signIn(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoggingIn = false
        }
    }
}

private struct AppTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.appBodyMedium)
            .foregroundStyle(.textPrimary)
            .textFieldStyle(.plain)
            .padding(AppSpacing.medium)
            .background(.surfaceSecondary, in: RoundedRectangle(cornerRadius: AppRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .stroke(.borderPrimary, lineWidth: 1)
            }
    }
}

private extension View {
    func appTextFieldStyle() -> some View {
        modifier(AppTextFieldStyle())
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environment(SessionStore.previewUnauthenticated)
    }
    .preferredColorScheme(.dark)
}
