import SwiftUI

struct CreditsView: View {
    @ObservedObject private var viewModel: CreditsViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var selectedTariffId: String?

    init(viewModel: CreditsViewModel) {
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
        .onAppear {
            viewModel.load()
            viewModel.getTariffs()
        }
        .sheet(isPresented: $viewModel.state.isDetailsSheetPresented) {
            loanDetailsSheet
        }
    }
}

private extension CreditsView {
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
        isDark ? Color.white.opacity(0.05) : Color.AppColor.backgroundMain
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
        isDark ? Color.white.opacity(0.10) : Color.AppColor.primaryPink.opacity(0.25)
    }

    var subtleBorderColor: Color {
        isDark ? Color.white.opacity(0.14) : Color.AppColor.textSecondary.opacity(0.3)
    }

    var rowBackgroundColor: Color {
        isDark ? Color.white.opacity(0.04) : Color.clear
    }

    var shadowColor: Color {
        isDark ? .clear : Color.black.opacity(0.04)
    }

    var title: some View {
        Text(AppStrings.Tabs.credits.localization)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(primaryTextColor)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
    }

    var content: some View {
        ScrollView(.vertical) {
            VStack(spacing: 12) {
                creditRatingCard
                takeLoanCard
                loansListCard
                errorBlock
            }
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Credit Rating Card

    var creditRatingCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Кредитный рейтинг")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(titleTextColor)

            if viewModel.state.isRatingLoading {
                HStack {
                    ProgressView()
                        .tint(Color.AppColor.primaryPink)
                        .scaleEffect(0.8)

                    Text("Загружаем рейтинг...")
                        .font(.system(size: 13))
                        .foregroundStyle(secondaryTextColor)
                }
            } else if let rating = viewModel.state.creditRating {
                HStack(alignment: .center, spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(isDark ? Color.white.opacity(0.12) : Color.AppColor.backgroundAlt, lineWidth: 6)
                            .frame(width: 60, height: 60)

                        Circle()
                            .trim(from: 0, to: CGFloat(rating.score) / 100)
                            .stroke(ratingColor(rating.rating), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))

                        Text("\(rating.score)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(primaryTextColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(rating.rating.label)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ratingColor(rating.rating))

                        Text(rating.description)
                            .font(.system(size: 12))
                            .foregroundStyle(secondaryTextColor)
                    }
                }
            } else if let error = viewModel.state.ratingErrorText {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(secondaryTextColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(cardBorderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: shadowColor, radius: 10, x: 0, y: 4)
    }

    private func ratingColor(_ level: CreditRating.RatingLevel) -> Color {
        switch level {
        case .excellent: return Color.AppColor.textSuccess
        case .good:      return Color.AppColor.primaryPink
        case .average:   return Color.AppColor.textWarning
        case .poor:      return Color.AppColor.textError
        }
    }

    // MARK: - Take loan

    var takeLoanCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Взять кредит")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(titleTextColor)

            tariffPicker

            amountStepper(
                title: "Сумма кредита",
                value: $viewModel.state.takeAmount,
                step: 1_000
            )

            CommonButton(
                title: AppStrings.Credits.take,
                style: .primary,
                isLoading: viewModel.state.isActionLoading,
                disabled: selectedTariffId == nil || viewModel.state.isActionLoading
            ) {
                if let tariff = viewModel.state.tariffs.first(where: { $0.id == selectedTariffId }) {
                    viewModel.state.tariffName = tariff.name
                    viewModel.takeLoan()
                }
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

    var tariffPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Выберите тариф")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(secondaryTextColor)

            if viewModel.state.tariffs.isEmpty {
                HStack {
                    ProgressView()
                        .tint(Color.AppColor.primaryPink)
                        .scaleEffect(0.8)

                    Text("Загрузка тарифов...")
                        .font(.system(size: 13))
                        .foregroundStyle(secondaryTextColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            } else {
                Menu {
                    ForEach(viewModel.state.tariffs, id: \.id) { tariff in
                        Button {
                            selectedTariffId = tariff.id
                            viewModel.state.tariffName = tariff.name
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(tariff.name)
                                        .font(.system(size: 14, weight: .medium))

                                    Text("\(Int(tariff.interestRate * 100))% годовых")
                                        .font(.system(size: 12))
                                        .foregroundStyle(secondaryTextColor)
                                }

                                if selectedTariffId == tariff.id {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.AppColor.primaryPink)
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        if let selectedId = selectedTariffId,
                           let selected = viewModel.state.tariffs.first(where: { $0.id == selectedId }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selected.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(primaryTextColor)

                                Text("\(Int(selected.interestRate * 100))% годовых")
                                    .font(.system(size: 12))
                                    .foregroundStyle(secondaryTextColor)
                            }
                        } else {
                            Text("Выберите тариф")
                                .font(.system(size: 16))
                                .foregroundStyle(secondaryTextColor)
                        }

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundStyle(secondaryTextColor)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(secondaryCardBackgroundColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(subtleBorderColor, lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Loans list

    var loansListCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Мои кредиты")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(titleTextColor)

            if viewModel.state.isLoading {
                ProgressView()
                    .tint(Color.AppColor.primaryPink)
                    .padding(.top, 8)
            } else if viewModel.state.loans.isEmpty {
                Text("У вас пока нет кредитов")
                    .font(.system(size: 14))
                    .foregroundStyle(secondaryTextColor)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.state.loans, id: \.loanId) { loan in
                        loanRow(loan)
                    }
                }
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

    func loanRow(_ loan: Credit) -> some View {
        Button {
            viewModel.selectLoan(loanId: loan.loanId)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(loan.tariffName ?? "Кредит")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(primaryTextColor)

                    Spacer()

                    Text(loan.isActive ? "Активен" : "Закрыт")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(loan.isActive ? Color.AppColor.textSuccess : secondaryTextColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill((loan.isActive ? Color.AppColor.textSuccess : secondaryTextColor).opacity(isDark ? 0.18 : 0.1))
                        )
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Сумма")
                            .font(.system(size: 11))
                            .foregroundStyle(secondaryTextColor)

                        Text(formatMoney(loan.initialAmount))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(primaryTextColor)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Остаток")
                            .font(.system(size: 11))
                            .foregroundStyle(secondaryTextColor)

                        Text(formatMoney(loan.remainingAmount))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(loan.remainingAmount > 0 ? Color.AppColor.textError : Color.AppColor.textSuccess)
                    }
                }
            }
            .padding(12)
            .background(rowBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.AppColor.primaryPink.opacity(isDark ? 0.25 : 0.5), lineWidth: 1.2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sheet

    var loanDetailsSheet: some View {
        LoanDetailsSheet(viewModel: viewModel)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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

    // MARK: - Helpers UI

    func amountStepper(title: String, value: Binding<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(secondaryTextColor)

            HStack {
                Text("\(Int(value.wrappedValue)) ₽")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.AppColor.primaryPink)

                Spacer()

                Stepper("", value: value, in: 1...10_000_000, step: step)
                    .labelsHidden()
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(secondaryCardBackgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(subtleBorderColor, lineWidth: 1)
            )
        }
    }

    func formatMoney(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }
}
