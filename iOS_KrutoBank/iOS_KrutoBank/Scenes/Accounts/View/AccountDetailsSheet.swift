import SwiftUI

struct AccountDetailsSheet: View {
    @ObservedObject var viewModel: AccountsViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader

            if let account = viewModel.state.selectedAccount {
                accountInfoCard(account)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }

            tabSelector

            TabView(selection: $selectedTab) {
                operationsTab.tag(0)
                managementTab.tag(1)
                transferTab.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(screenBackgroundColor.ignoresSafeArea())
        .onAppear { viewModel.loadAccountData() }
    }
}

private extension AccountDetailsSheet {
    var isDark: Bool {
        themeManager.theme == .dark
    }

    var screenBackgroundColor: Color {
        isDark ? .black : Color.AppColor.backgroundMain
    }

    var cardBackgroundColor: Color {
        isDark ? Color(.systemGray6).opacity(0.16) : Color.AppColor.primaryWhite
    }

    var secondaryCardBackgroundColor: Color {
        isDark ? Color.white.opacity(0.05) : Color.AppColor.backgroundAlt
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

    var subtleLineColor: Color {
        isDark ? Color.white.opacity(0.12) : Color.AppColor.primaryPink.opacity(0.2)
    }

    var cardBorderColor: Color {
        isDark ? Color.white.opacity(0.10) : Color.AppColor.primaryPink.opacity(0.3)
    }

    var pinkTintBackground: Color {
        isDark ? Color.AppColor.primaryPink.opacity(0.18) : Color.AppColor.primaryPink.opacity(0.1)
    }

    var successTintBackground: Color {
        isDark ? Color.green.opacity(0.18) : Color.AppColor.textSuccess.opacity(0.1)
    }

    var errorTintBackground: Color {
        isDark ? Color.red.opacity(0.18) : Color.AppColor.textError.opacity(0.1)
    }

    var shadowColor: Color {
        isDark ? .clear : Color.black.opacity(0.04)
    }

    var sheetHeader: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(secondaryTextColor.opacity(0.35))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            HStack {
                Text("Детали счета")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(primaryTextColor)

                Spacer()

                if viewModel.webSocketConnected {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.AppColor.textSuccess)
                            .frame(width: 7, height: 7)
                        Text("Live")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.AppColor.textSuccess)
                    }
                }

                if let accountId = viewModel.state.selectedAccountId {
                    Button {
                        viewModel.toggleHidden(accountId: accountId)
                    } label: {
                        Image(systemName: viewModel.isHidden(accountId) ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(secondaryTextColor)
                    }
                    .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    func accountInfoCard(_ account: Account) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(account.name.isEmpty ? "Без названия" : account.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(primaryTextColor)

                Spacer()

                Text(account.currency)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.AppColor.primaryPink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(pinkTintBackground))

                if account.isClosed {
                    Text("Закрыт")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.AppColor.textError)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(errorTintBackground))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Текущий баланс")
                    .font(.system(size: 12))
                    .foregroundStyle(secondaryTextColor)

                Text("\(formatMoney(account.balance)) \(account.currencySymbol)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.AppColor.primaryPink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardBorderColor, lineWidth: 1)
        )
        .shadow(color: shadowColor, radius: 10, x: 0, y: 4)
    }

    func detailItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(secondaryTextColor)
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(primaryTextColor)
        }
    }

    var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "История", icon: "clock.arrow.circlepath", tab: 0)
            tabButton(title: "Управление", icon: "slider.horizontal.3", tab: 1)
            tabButton(title: "Перевод", icon: "arrow.left.arrow.right", tab: 2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    func tabButton(title: String, icon: String, tab: Int) -> some View {
        Button {
            withAnimation(.easeInOut) { selectedTab = tab }
        } label: {
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                }

                Rectangle()
                    .fill(selectedTab == tab ? Color.AppColor.primaryPink : Color.clear)
                    .frame(height: 2)
            }
            .foregroundStyle(selectedTab == tab ? Color.AppColor.primaryPink : secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
    }

    var operationsTab: some View {
        VStack(spacing: 0) {
            if let errorText = viewModel.state.operationsErrorText {
                errorView(errorText)
            } else if let operations = viewModel.state.accountOperations {
                if operations.isEmpty {
                    emptyOperationsView
                } else {
                    operationsList(operations)
                }
            } else {
                loadingView
            }
        }
        .padding(.top, 8)
    }

    var loadingView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            ProgressView()
                .tint(Color.AppColor.primaryPink)
            Text("Загружаем историю...")
                .font(.system(size: 14))
                .foregroundStyle(secondaryTextColor)
            Spacer(minLength: 40)
        }
    }

    var emptyOperationsView: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 40)
            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 40))
                .foregroundStyle(secondaryTextColor.opacity(0.55))
            Text("История операций пуста")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(primaryTextColor)
            Text("Пополняйте или снимайте средства\nсо счета, чтобы видеть историю")
                .font(.system(size: 13))
                .foregroundStyle(secondaryTextColor)
                .multilineTextAlignment(.center)
            Spacer(minLength: 40)
        }
    }

    func errorView(_ errorText: String) -> some View {
        VStack(spacing: 12) {
            Spacer(minLength: 40)
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Color.AppColor.textError)
            Text(errorText)
                .font(.system(size: 14))
                .foregroundStyle(Color.AppColor.textError)
                .multilineTextAlignment(.center)
            Button("Повторить") {
                viewModel.loadAccountData()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color.AppColor.primaryPink)
            Spacer(minLength: 40)
        }
    }

    func operationsList(_ operations: [AccountOperation]) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(operations) { operation in
                    operationRow(operation)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    func operationRow(_ operation: AccountOperation) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(operation.type.color.opacity(isDark ? 0.16 : 0.10))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: operation.type.iconName)
                        .font(.system(size: 16))
                        .foregroundStyle(operation.type.color)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(operation.type.displayedName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(primaryTextColor)

                Text(operation.formattedDate)
                    .font(.system(size: 11))
                    .foregroundStyle(secondaryTextColor)
            }

            Spacer()

            Text(operation.formattedAmount)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(operation.type.color)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(operation.type.color.opacity(isDark ? 0.28 : 0.2), lineWidth: 1)
        )
    }

    var managementTab: some View {
        VStack(spacing: 16) {
            if let account = viewModel.state.selectedAccount, !account.isClosed {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Сумма операции")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(primaryTextColor)

                    HStack {
                        Text("\(Int(viewModel.state.amountInput)) \(account.currencySymbol)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.AppColor.primaryPink)

                        Spacer()

                        Slider(value: $viewModel.state.amountInput, in: 100...20000, step: 100)
                            .tint(Color.AppColor.primaryPink)
                            .frame(width: 180)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(cardBackgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(subtleLineColor, lineWidth: 1)
                )

                HStack(spacing: 12) {
                    Button {
                        viewModel.depositSelectedAccount()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 24))
                            Text("Пополнить")
                                .font(.system(size: 12))
                        }
                        .foregroundStyle(Color.AppColor.textSuccess)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(successTintBackground)
                        )
                    }

                    Button {
                        viewModel.withdrawSelectedAccount()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 24))
                            Text("Снять")
                                .font(.system(size: 12))
                        }
                        .foregroundStyle(Color.AppColor.textError)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(errorTintBackground)
                        )
                    }
                }

                Button {
                    viewModel.closeSelectedAccount()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                        Text("Закрыть счет")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(Color.AppColor.textError)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.AppColor.textError, lineWidth: 1)
                    )
                }
                .disabled(viewModel.state.isActionLoading)

            } else {
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(secondaryTextColor)
                    Text("Счет закрыт")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(primaryTextColor)
                    Text("Операции по закрытому счету недоступны")
                        .font(.system(size: 13))
                        .foregroundStyle(secondaryTextColor)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    var transferTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Перевод средств")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(titleTextColor)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Номер телефона получателя")
                        .font(.system(size: 13))
                        .foregroundStyle(secondaryTextColor)

                    TextField("Введите номер для перевода", text: $viewModel.state.transferTargetAccountId)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(secondaryCardBackgroundColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(subtleLineColor, lineWidth: 1)
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(primaryTextColor)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Сумма перевода")
                        .font(.system(size: 13))
                        .foregroundStyle(secondaryTextColor)

                    HStack {
                        Text("\(Int(viewModel.state.transferAmount)) \(viewModel.state.selectedAccount?.currencySymbol ?? "₽")")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.AppColor.primaryPink)

                        Spacer()

                        Slider(value: $viewModel.state.transferAmount, in: 100...20000, step: 100)
                            .tint(Color.AppColor.primaryPink)
                            .frame(width: 160)
                    }
                }

                if let transferError = viewModel.state.transferError {
                    Text(transferError)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.AppColor.textError)
                }

                CommonButton(
                    title: "Перевести",
                    style: .primary,
                    isLoading: viewModel.state.isActionLoading,
                    disabled: viewModel.state.transferTargetAccountId.isEmpty || viewModel.state.isActionLoading
                ) {
                    viewModel.transferFromSelectedAccount()
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }

    func formatMoney(_ value: Double) -> String {
        if value.rounded() == value { return String(Int(value)) }
        return String(format: "%.2f", value)
    }
}
