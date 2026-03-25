import SwiftUI

struct ProfileView: View {
    @ObservedObject private var viewModel: ProfileViewModel
    @ObservedObject private var themeManager = ThemeManager.shared

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            screenBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                title
                content
                themeSection
                Spacer()
                logoutButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .onAppear {
            viewModel.load()
            themeManager.loadFromServer()
        }
    }
}

private extension ProfileView {
    var isDark: Bool {
        themeManager.theme == .dark
    }

    var screenBackgroundColor: Color {
        isDark ? .black : Color.AppColor.backgroundMain
    }

    var cardBackgroundColor: Color {
        isDark ? Color(.systemGray6).opacity(0.16) : Color.AppColor.primaryWhite
    }

    var primaryTextColor: Color {
        isDark ? .white : Color.AppColor.textPrimary
    }

    var secondaryTextColor: Color {
        isDark ? Color.white.opacity(0.7) : Color.AppColor.textSecondary
    }

    var titleTextColor: Color {
        isDark ? .white : Color.AppColor.primaryDark
    }

    var dividerColor: Color {
        isDark ? Color.white.opacity(0.12) : Color.AppColor.primaryPink.opacity(0.18)
    }

    var cardBorderColor: Color {
        isDark ? Color.white.opacity(0.10) : Color.AppColor.primaryPink.opacity(0.25)
    }

    var shadowColor: Color {
        isDark ? .clear : Color.black.opacity(0.04)
    }

    var title: some View {
        Text(AppStrings.Tabs.profile.localization)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(primaryTextColor)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    var content: some View {
        VStack(spacing: 12) {
            if viewModel.state.isLoading {
                ProgressView()
                    .tint(Color.AppColor.primaryPink)
                    .padding(.top, 12)
            } else if let user = viewModel.state.user {
                profileContent(user: user)
            } else {
                errorBlock
            }
        }
    }

    func profileContent(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            profileRow(title: AppStrings.Profile.fullName, value: user.fullName)

            Divider()
                .overlay(dividerColor)

            profileRow(title: AppStrings.Profile.phone, value: user.phone ?? "-")

            Divider()
                .overlay(dividerColor)

            profileRow(title: AppStrings.Profile.email, value: user.email ?? "-")

            Divider()
                .overlay(dividerColor)

            profileRow(title: AppStrings.Profile.role, value: user.role.title)

            if user.isBlocked {
                Divider()
                    .overlay(dividerColor)

                Text(AppStrings.Profile.blocked)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.AppColor.textError)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(cardBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(cardBorderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: shadowColor, radius: 10, x: 0, y: 4)
    }

    func profileRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.localization)
                .font(.system(size: 12))
                .foregroundStyle(secondaryTextColor)

            Text(value.localization)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(titleTextColor)
        }
    }

    @ViewBuilder
    var errorBlock: some View {
        if let errorText = viewModel.state.errorText {
            Text(errorText.localization)
                .font(.system(size: 13))
                .foregroundStyle(Color.AppColor.textError)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        } else {
            Text(AppStrings.Profile.noData.localization)
                .font(.system(size: 13))
                .foregroundStyle(secondaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
    }

    // MARK: - Theme section

    var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Настройки приложения")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(titleTextColor)

            HStack {
                Text("Тема оформления")
                    .font(.system(size: 14))
                    .foregroundStyle(primaryTextColor)

                Spacer()

                Picker("Тема", selection: $themeManager.theme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
                .colorScheme(isDark ? .dark : .light)
            }
        }
        .padding(16)
        .background(cardBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(cardBorderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: shadowColor, radius: 10, x: 0, y: 4)
    }

    var logoutButton: some View {
        CommonButton(
            title: AppStrings.Profile.logout,
            style: .primary,
            isLoading: viewModel.state.isLogoutLoading,
            disabled: viewModel.state.isLoading || viewModel.state.isLogoutLoading
        ) {
            viewModel.logout()
        }
    }
}
