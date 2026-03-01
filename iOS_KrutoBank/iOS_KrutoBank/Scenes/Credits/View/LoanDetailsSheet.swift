import SwiftUI

struct LoanDetailsSheet: View {
    @ObservedObject private var viewModel: CreditsViewModel
    @State private var showHistory = true

    init(viewModel: CreditsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if let loan = viewModel.selectedLoan {
                loanInfoCard(loan)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                tabSelector

                if showHistory {
                    LoanOperationsList(
                        operations: viewModel.state.loanOperations,
                        isLoading: viewModel.state.isOperationsLoading,
                        errorText: viewModel.state.operationsErrorText,
                        onRetry: {
                            viewModel.loadLoanHistory()
                        }
                    )
                    .transition(.opacity)
                } else {
                    repaymentPanel(loan: loan)
                        .transition(.opacity)
                }
            } else {
                VStack(spacing: 16) {
                    Spacer()
                    Text("Нет данных по кредиту")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.AppColor.textSecondary)
                    Spacer()
                }
            }

            detailsErrorBlock
        }
        .background(Color.AppColor.backgroundMain.ignoresSafeArea())
        .onAppear {
            viewModel.loadLoanHistory()
        }
        .onDisappear { viewModel.dismissDetails() }
    }
}

private extension LoanDetailsSheet {
    var header: some View {
        HStack {
            Spacer()
            Text("Детали кредита")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.AppColor.textPrimary)
            Spacer()
            Button {
                viewModel.dismissDetails()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.AppColor.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    func loanInfoCard(_ loan: CreditResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loan.tariffName ?? "Кредит")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.AppColor.textPrimary)

                Spacer()

                Text(loan.isActive ? "Активен" : "Закрыт")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(loan.isActive ? Color.AppColor.textSuccess : Color.AppColor.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((loan.isActive ? Color.AppColor.textSuccess : Color.AppColor.textSecondary).opacity(0.1))
                    )
            }

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Сумма кредита")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.AppColor.textSecondary)
                    Text(formatMoney(loan.initialAmount))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.AppColor.primaryPink)
                }

                Divider()
                    .frame(height: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Остаток")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.AppColor.textSecondary)
                    Text(formatMoney(loan.remainingAmount))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(loan.remainingAmount > 0 ? Color.AppColor.textError : Color.AppColor.textSuccess)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if loan.initialAmount > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Погашено")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.AppColor.textSecondary)
                        Spacer()
                        Text("\(Int((loan.initialAmount - loan.remainingAmount) / loan.initialAmount * 100))%")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.AppColor.textPrimary)
                    }
                }
            }

            HStack {
                Label(
                    title: { Text("\(Int(loan.interestRate * 100))% годовых") },
                    icon: { Image(systemName: "percent") }
                )
                .font(.system(size: 12))
                .foregroundStyle(Color.AppColor.textSecondary)

                Spacer()

                Label(
                    title: { Text(formatDate(loan.createdAt)) },
                    icon: { Image(systemName: "calendar") }
                )
                .font(.system(size: 12))
                .foregroundStyle(Color.AppColor.textSecondary)
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

    var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "История", icon: "clock.arrow.circlepath", isSelected: showHistory) {
                withAnimation(.easeInOut) {
                    showHistory = true
                }
            }

            tabButton(title: "Погашение", icon: "creditcard", isSelected: !showHistory) {
                withAnimation(.easeInOut) {
                    showHistory = false
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    func tabButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                }

                Rectangle()
                    .fill(isSelected ? Color.AppColor.primaryPink : Color.clear)
                    .frame(height: 2)
            }
            .foregroundStyle(isSelected ? Color.AppColor.primaryPink : Color.AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    func repaymentPanel(loan: CreditResponse) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                if loan.isActive && loan.remainingAmount > 0 {
                    HStack {
                        Text("Доступно для погашения:")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.AppColor.textSecondary)

                        Spacer()

                        Text(formatMoney(loan.remainingAmount))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.AppColor.textPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Сумма погашения")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.AppColor.textPrimary)
                            .padding(.horizontal, 20)

                        amountSliderPanel
                    }

                    CommonButton(
                        title: AppStrings.Credits.repay,
                        style: .primary,
                        isLoading: viewModel.state.isActionLoading,
                        disabled: !viewModel.canRepayLoan
                    ) {
                        viewModel.repaySelectedLoan()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                } else if !loan.isActive {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.AppColor.textSuccess)

                        Text("Кредит полностью погашен")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.AppColor.textPrimary)

                        Text("Операции по погашению недоступны")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .padding(.horizontal, 20)
                } else if loan.remainingAmount <= 0 {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.AppColor.textSuccess)

                        Text("Кредит погашен")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.AppColor.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }

                Spacer(minLength: 20)
            }
            .padding(.vertical, 12)
        }
    }

    var amountSliderPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(Int(viewModel.state.repayAmount)) ₽")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.AppColor.primaryPink)

                Spacer()

                HStack(spacing: 8) {
                    quickAmountButton(500)
                    quickAmountButton(1000)
                    quickAmountButton(5000)
                }
            }

            Slider(
                value: $viewModel.state.repayAmount,
                in: 100...max(100, viewModel.selectedLoan?.remainingAmount ?? 10000),
                step: 100
            )
            .tint(Color.AppColor.primaryPink)

            HStack {
                Text("100 ₽")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.AppColor.textSecondary)

                Spacer()

                if let loan = viewModel.selectedLoan {
                    Text(formatMoney(loan.remainingAmount))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.AppColor.textPrimary)
                }
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
        .padding(.horizontal, 20)
    }

    func quickAmountButton(_ amount: Double) -> some View {
        Button {
            if let loan = viewModel.selectedLoan {
                viewModel.state.repayAmount = min(amount, loan.remainingAmount)
            }
        } label: {
            Text("\(Int(amount))")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.AppColor.primaryPink)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.AppColor.primaryPink.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    var detailsErrorBlock: some View {
        if let errorText = viewModel.state.detailsErrorText {
            Text(errorText.localization)
                .font(.system(size: 13))
                .foregroundStyle(Color.AppColor.textError)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.AppColor.textError.opacity(0.1))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
    }

    // MARK: - Helpers

    func progressColor(loan: CreditResponse) -> Color {
        let progress = (loan.initialAmount - loan.remainingAmount) / loan.initialAmount
        if progress < 0.3 {
            return Color.AppColor.textError
        } else if progress < 0.7 {
            return Color.AppColor.primaryPink
        } else {
            return Color.AppColor.textSuccess
        }
    }

    func formatMoney(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }

    func formatDate(_ dateString: String) -> String {
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
}
