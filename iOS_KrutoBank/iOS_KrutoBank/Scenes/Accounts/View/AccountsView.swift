import SwiftUI

struct AccountsView: View {
    @ObservedObject private var viewModel: AccountsViewModel
    @ObservedObject private var themeManager = ThemeManager.shared

    init(viewModel: AccountsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            screenBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                title
                content
            }
            .padding(.horizontal, 20)
        }
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
    var isDark: Bool {
        themeManager.theme == .dark
    }

    var screenBackgroundColor: Color {
        isDark ? Color.black : Color.AppColor.backgroundMain
    }

    var cardBackgroundColor: Color {
        isDark ? Color(.systemGray6).opacity(0.18) : Color.AppColor.primaryWhite
    }

    var primaryTextColor: Color {
        isDark ? Color.white : Color.AppColor.textPrimary
    }

    var secondaryTextColor: Color {
        isDark ? Color.white.opacity(0.7) : Color.AppColor.textSecondary
    }

    var titleTextColor: Color {
        isDark ? Color.white : Color.AppColor.primaryDark
    }

    var borderColor: Color {
        isDark ? Color.white.opacity(0.12) : Color.AppColor.primaryPink.opacity(0.5)
    }

    var rowBackgroundColor: Color {
        isDark ? Color.white.opacity(0.04) : Color.clear
    }

    var background: some View {
        screenBackgroundColor.ignoresSafeArea()
    }

    var title: some View {
        Text(AppStrings.Tabs.accounts.localization)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(primaryTextColor)
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
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Open Account

    var openAccountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Открыть новый счёт")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(titleTextColor)

            TextInput(
                text: $viewModel.state.openAccountName,
                placeholder: "Название (например: Основной)",
                type: .text,
                backgroundColor: isDark ? Color.white.opacity(0.04) : Color.AppColor.backgroundMain,
                textColor: isDark ? Color.white : Color.AppColor.textPrimary,
                keyboardType: .default,
                textContentType: .none
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Валюта счёта")
                    .font(.system(size: 13))
                    .foregroundStyle(secondaryTextColor)

                Picker("Валюта", selection: $viewModel.state.selectedCurrency) {
                    ForEach(AccountCurrency.allCases, id: \.self) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
                .pickerStyle(.segmented)
                .colorScheme(isDark ? .dark : .light)
            }

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
        .background(cardBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(borderColor, lineWidth: isDark ? 1 : 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(
            color: isDark ? .clear : Color.black.opacity(0.04),
            radius: 10,
            x: 0,
            y: 4
        )
    }

    // MARK: - Accounts List

    var accountsListCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Мои счета")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(titleTextColor)

                Spacer()

                Button {
                    viewModel.state.showHiddenAccounts.toggle()
                } label: {
                    Image(systemName: viewModel.state.showHiddenAccounts ? "eye.fill" : "eye.slash")
                        .font(.system(size: 14))
                        .foregroundStyle(secondaryTextColor)
                }
            }

            if viewModel.state.isLoading {
                ProgressView()
                    .tint(Color.AppColor.primaryPink)
                    .padding(.top, 8)
            } else if viewModel.visibleAccounts.isEmpty {
                Text(viewModel.state.accounts.isEmpty ? "У вас пока нет счетов" : "Все счета скрыты")
                    .font(.system(size: 13))
                    .foregroundStyle(secondaryTextColor)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.visibleAccounts) { account in
                        accountRow(account)
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(borderColor, lineWidth: isDark ? 1 : 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(
            color: isDark ? .clear : Color.black.opacity(0.04),
            radius: 10,
            x: 0,
            y: 4
        )
    }

    func accountRow(_ account: UserAccount) -> some View {
        Button {
            viewModel.selectAccount(accountId: account.id)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(account.name.isEmpty ? "Без названия" : account.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(primaryTextColor)

                    Text("Баланс: \(formatMoney(account.balance)) \(account.currencySymbol)")
                        .font(.system(size: 13))
                        .foregroundStyle(secondaryTextColor)
                }

                Spacer()

                if themeManager.isHidden(account.id) {
                    Image(systemName: "eye.slash")
                        .font(.system(size: 12))
                        .foregroundStyle(secondaryTextColor)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(secondaryTextColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(rowBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
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
