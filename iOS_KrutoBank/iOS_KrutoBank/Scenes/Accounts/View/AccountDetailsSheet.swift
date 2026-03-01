import SwiftUI

struct AccountDetailsSheet: View {
    @ObservedObject var viewModel: AccountsViewModel
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
                operationsTab
                    .tag(0)
                managementTab
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.AppColor.backgroundMain.ignoresSafeArea())
        .onAppear {
            viewModel.loadAccountData()
        }
    }
}

private extension AccountDetailsSheet {
    var sheetHeader: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.AppColor.textSecondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("Детали счета")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
        }
    }

    func accountInfoCard(_ account: AccountResponse) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(account.name.flatMap { $0.isEmpty ? nil : $0 } ?? "Без названия")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.AppColor.textPrimary)

                Spacer()

                if account.isClosed {
                    Text("Закрыт")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.AppColor.textError)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.AppColor.textError.opacity(0.1))
                        )
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Текущий баланс")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.AppColor.textSecondary)

                Text("\(formatMoney(account.balance)) ₽")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.AppColor.primaryPink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                detailItem(
                    title: "Открыт",
                    value: formatDateString(account.openedAt)
                )

                if let closedAt = account.closedAt {
                    Spacer()
                    detailItem(
                        title: "Закрыт",
                        value: formatDateString(closedAt)
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.AppColor.primaryWhite)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.AppColor.primaryPink.opacity(0.3), lineWidth: 1)
        )
    }

    func detailItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(Color.AppColor.textSecondary)

            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.AppColor.textPrimary)
        }
    }

    var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "История", icon: "clock.arrow.circlepath", tab: 0)
            tabButton(title: "Управление", icon: "slider.horizontal.3", tab: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    func tabButton(title: String, icon: String, tab: Int) -> some View {
        Button {
            withAnimation(.easeInOut) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                }

                Rectangle()
                    .fill(selectedTab == tab ? Color.AppColor.primaryPink : Color.clear)
                    .frame(height: 2)
            }
            .foregroundStyle(selectedTab == tab ? Color.AppColor.primaryPink : Color.AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Operations Tab

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
                .foregroundStyle(Color.AppColor.textSecondary)
            Spacer(minLength: 40)
        }
    }

    var emptyOperationsView: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 40)

            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 40))
                .foregroundStyle(Color.AppColor.textSecondary.opacity(0.5))

            Text("История операций пуста")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.AppColor.textPrimary)

            Text("Пополняйте или снимайте средства\nсо счета, чтобы видеть историю")
                .font(.system(size: 13))
                .foregroundStyle(Color.AppColor.textSecondary)
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

    func operationsList(_ operations: [AccountOperationResponse]) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(operations, id: \.id) { operation in
                    operationRow(operation)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    func operationRow(_ operation: AccountOperationResponse) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(operation.type.color.opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: operation.type.iconName)
                        .font(.system(size: 16))
                        .foregroundStyle(operation.type.color)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(operation.type.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.AppColor.textPrimary)

                Text(operation.formattedDate)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.AppColor.textSecondary)
            }

            Spacer()

            Text(operation.formattedAmount)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(operation.type == .deposit ?
                    Color.AppColor.textSuccess : Color.AppColor.textError)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.AppColor.primaryWhite)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(operation.type.color.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Management Tab

    var managementTab: some View {
        VStack(spacing: 16) {
            if let account = viewModel.state.selectedAccount, !account.isClosed {
                // Сумма для операций
                VStack(alignment: .leading, spacing: 8) {
                    Text("Сумма операции")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.AppColor.textPrimary)

                    HStack {
                        Text("\(Int(viewModel.state.amountInput)) ₽")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.AppColor.primaryPink)

                        Spacer()

                        Slider(
                            value: $viewModel.state.amountInput,
                            in: 100...20000,
                            step: 100
                        )
                        .tint(Color.AppColor.primaryPink)
                        .frame(width: 180)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.AppColor.primaryWhite)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.AppColor.primaryPink.opacity(0.2), lineWidth: 1)
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
                                .fill(Color.AppColor.textSuccess.opacity(0.1))
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
                                .fill(Color.AppColor.textError.opacity(0.1))
                        )
                    }
                }

                if !account.isClosed {
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
                }
            } else if let account = viewModel.state.selectedAccount, account.isClosed {
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.AppColor.textSecondary)

                    Text("Счет закрыт")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.AppColor.textPrimary)

                    Text("Операции по закрытому счету недоступны")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.AppColor.textSecondary)
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

    // MARK: - Helpers

    func operationIcon(_ type: OperationType) -> String {
        switch type {
        case .deposit: 
            return "arrow.down.circle.fill"
        case .withdraw: 
            return "arrow.up.circle.fill"
        }
    }

    func operationColor(_ type: OperationType) -> Color {
        switch type {
        case .deposit:
            return Color.AppColor.textSuccess
        case .withdraw:
            return Color.AppColor.textError
        }
    }

    func operationTypeText(_ type: OperationType) -> String {
        switch type {
        case .deposit: return "Пополнение"
        case .withdraw: return "Списание"
        }
    }

    func formatDateString(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: dateString) else {
            return dateString
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .none
        outputFormatter.locale = Locale(identifier: "ru_RU")

        return outputFormatter.string(from: date)
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }

    func formatMoney(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }
}
