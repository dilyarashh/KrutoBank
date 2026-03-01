import SwiftUI

struct ProfileView: View {
    @ObservedObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 16) {
            title
            content
            Spacer()
            logoutButton
        }
        .background(background)
        .onAppear {
            viewModel.load()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

private extension ProfileView {
    var background: some View {
        Color.AppColor.backgroundMain.ignoresSafeArea()
    }

    var title: some View {
        Text(AppStrings.Tabs.profile.localization)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(Color.AppColor.textPrimary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    var content: some View {
        VStack(spacing: 12) {
            if viewModel.state.isLoading {
                ProgressView()
                    .tint(Color.AppColor.primaryDark)
                    .padding(.top, 12)
            } else if let user = viewModel.state.user {
                profileContent(user: user)
            } else {
                errorBlock
            }
        }
    }

    func profileContent(user: UserResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            profileRow(title: AppStrings.Profile.fullName, value: viewModel.fullName(from: user))

            Divider()

            profileRow(title: AppStrings.Profile.phone, value: user.phone ?? "-")

            Divider()

            profileRow(title: AppStrings.Profile.email, value: user.email ?? "-")

            Divider()

            profileRow(title: AppStrings.Profile.role, value: user.role.rawValue)

            if user.isBlocked {
                Divider()

                Text(AppStrings.Profile.blocked)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.AppColor.textError)
                    .padding(.top, 4)
            }
        }
    }

    func profileRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.localization)
                .font(.system(size: 12))
                .foregroundStyle(Color.AppColor.textSecondary)

            Text(value.localization)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.AppColor.primaryDark)
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
                .foregroundStyle(Color.AppColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
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
