import SwiftUI

struct AccountsView: View {
    @ObservedObject private var viewModel: AccountsViewModel

    init(viewModel: AccountsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 16) {
            title
            content
            Spacer(minLength: 0)
        }
        .background(background)
        .padding(.horizontal, 20)
        .onAppear { viewModel.load() }
        .sheet(isPresented: $viewModel.state.isDetailsSheetPresented) {
            AccountDetailsSheet(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .dismissKeyboardOnTap()
    }
}

private extension AccountsView {
    var background: some View {
        Color.AppColor.backgroundMain.ignoresSafeArea()
    }

    var title: some View {
        Text(AppStrings.Tabs.accounts.localization)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(Color.AppColor.textPrimary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
    }

    var content: some View {
        ScrollView(.vertical) {
            VStack(spacing: 12) {
                openAccountCard
                accountsListCard
                errorBlock
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Open Account

    var openAccountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Открыть новый счёт")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.AppColor.primaryDark)

            TextInput(
                text: $viewModel.state.openAccountName,
                placeholder: "Название (например: Основной)",
                type: .text,
                keyboardType: .default,
                textContentType: .none
            )

            CommonButton(
                title: AppStrings.Accounts.openAccount,
                style: .primary,
                isLoading: viewModel.state.isActionLoading,
                disabled: viewModel.state.openAccountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || viewModel.state.isActionLoading
            ) {
                viewModel.openAccount()
            }
        }
        .padding(16)
        .background(Color.AppColor.primaryWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Accounts List

    var accountsListCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Мои счета")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.AppColor.primaryDark)

            if viewModel.state.isLoading {
                ProgressView()
                    .tint(Color.AppColor.primaryPink)
                    .padding(.top, 8)
            } else if viewModel.state.accounts.isEmpty {
                Text("У вас пока нет счетов")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.AppColor.textSecondary)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.state.accounts, id: \.accountId) { account in
                        accountRow(account)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.AppColor.primaryWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    func accountRow(_ account: UserAccountResponse) -> some View {
        Button {
            viewModel.selectAccount(accountId: account.accountId)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(account.accountName.isEmpty == false ? account.accountName : "Без названия")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.AppColor.textPrimary)

                Text("Баланс: \(formatMoney(account.balance)) ₽")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.AppColor.primaryPink.opacity(0.5), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sheet

    var accountDetailsSheet: some View {
        AccountDetailsSheet(viewModel: viewModel)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .background(Color.AppColor.backgroundMain.ignoresSafeArea())
    }

    // MARK: - Error

    @ViewBuilder
    var errorBlock: some View {
        if let errorText = viewModel.state.errorText {
            Text(errorText.localization)
                .font(.system(size: 13))
                .foregroundStyle(Color.AppColor.textError)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
    }

    // MARK: - Helpers

    func formatMoney(_ value: Double) -> String {
        if value.rounded() == value { return String(Int(value)) }
        return String(format: "%.2f", value)
    }
}
