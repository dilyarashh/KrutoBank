import SwiftUI

struct LoanDetailsSheet: View {
    @ObservedObject private var viewModel: CreditsViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showHistory = true

    init(viewModel: CreditsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            screenBackgroundColor
                .ignoresSafeArea()

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
                            .foregroundStyle(secondaryTextColor)
                        Spacer()
                    }
                }

                detailsErrorBlock
            }
        }
        .onAppear {
            viewModel.loadLoanHistory()
        }
        .onDisappear { viewModel.dismissDetails() }
    }
}

private extension LoanDetailsSheet {
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
        isDark ? Color.white.opacity(0.05) : Color.AppColor.primaryWhite
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

    var cardBorderColor: Color {
        isDark ? Color.white.opacity(0.10) : Color.AppColor.primaryPink.opacity(0.3)
    }

    var subtleBorderColor: Color {
        isDark ? Color.white.opacity(0.12) : Color.AppColor.primaryPink.opacity(0.2)
    }

    var successTintBackground: Color {
        isDark ? Color.AppColor.textSuccess.opacity(0.18) : Color.AppColor.textSuccess.opacity(0.1)
    }

    var errorTintBackground: Color {
        isDark ? Color.AppColor.textError.opacity(0.18) : Color.AppColor.textError.opacity(0.1)
    }

    var pinkTintBackground: Color {
        isDark ? Color.AppColor.primaryPink.opacity(0.18) : Color.AppColor.primaryPink.opacity(0.1)
    }

    var shadowColor: Color {
        isDark ? .clear : Color.black.opacity(0.04)
    }

    var header: some View {
        HStack {
            Spacer()

            Text("Детали кредита")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(primaryTextColor)

            Spacer()

            Button {
                viewModel.dismissDetails()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(secondaryTextColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    func loanInfoCard(_ loan: Credit) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loan.tariffName ?? "Кредит")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(primaryTextColor)

                Spacer()

                Text(loan.isActive ? "Активен" : "Закрыт")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(loan.isActive ? Color.AppColor.textSuccess : secondaryTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((loan.isActive ? successTintBackground : secondaryTextColor.opacity(isDark ? 0.18 : 0.1)))
                    )
            }

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Сумма кредита")
                        .font(.system(size: 11))
                        .foregroundStyle(secondaryTextColor)

                    Text(formatMoney(loan.initialAmount))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.AppColor.primaryPink)
                }

                Divider()
                    .frame(height: 30)
                    .overlay(subtleBorderColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Остаток")
                        .font(.system(size: 11))
                        .foregroundStyle(secondaryTextColor)

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
                            .foregroundStyle(secondaryTextColor)

                        Spacer()

                        Text("\(Int((loan.initialAmount - loan.remainingAmount) / loan.initialAmount * 100))%")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(primaryTextColor)
                    }
                }
            }

            HStack {
                Label(
                    title: { Text("\(Int(loan.interestRate * 100))% годовых") },
                    icon: { Image(systemName: "percent") }
                )
                .font(.system(size: 12))
                .foregroundStyle(secondaryTextColor)

                Spacer()

                Label(
                    title: { Text(formatDate(loan.createdAt)) },
                    icon: { Image(systemName: "calendar") }
                )
                .font(.system(size: 12))
                .foregroundStyle(secondaryTextColor)
            }
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
            .foregroundStyle(isSelected ? Color.AppColor.primaryPink : secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
    }

    func repaymentPanel(loan: Credit) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                if loan.isActive && loan.remainingAmount > 0 {
                    HStack {
                        Text("Доступно для погашения:")
                            .font(.system(size: 13))
                            .foregroundStyle(secondaryTextColor)

                        Spacer()

                        Text(formatMoney(loan.remainingAmount))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(primaryTextColor)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Сумма погашения")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(primaryTextColor)
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
                            .foregroundStyle(primaryTextColor)

                        Text("Операции по погашению недоступны")
                            .font(.system(size: 13))
                            .foregroundStyle(secondaryTextColor)
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
                            .foregroundStyle(primaryTextColor)
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
                    .foregroundStyle(secondaryTextColor)

                Spacer()

                if let loan = viewModel.selectedLoan {
                    Text(formatMoney(loan.remainingAmount))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(primaryTextColor)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(subtleBorderColor, lineWidth: 1)
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
                        .fill(pinkTintBackground)
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
                        .fill(errorTintBackground)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
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
