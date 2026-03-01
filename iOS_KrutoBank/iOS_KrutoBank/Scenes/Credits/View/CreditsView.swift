import SwiftUI

struct CreditsView: View {
    @ObservedObject private var viewModel: CreditsViewModel
    @State private var selectedTariffId: String?

    init(viewModel: CreditsViewModel) {
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
    var background: some View {
        Color.AppColor.backgroundMain.ignoresSafeArea()
    }

    var title: some View {
        Text(AppStrings.Tabs.credits.localization)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(Color.AppColor.textPrimary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
    }

    var content: some View {
        ScrollView(.vertical) {
            VStack(spacing: 12) {
                takeLoanCard
                loansListCard
                errorBlock
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Take loan

    var takeLoanCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Взять кредит")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.AppColor.primaryDark)

            // Picker для выбора тарифа
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
        .background(Color.AppColor.primaryWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    var tariffPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Выберите тариф")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.AppColor.textSecondary)

            if viewModel.state.tariffs.isEmpty {
                HStack {
                    ProgressView()
                        .tint(Color.AppColor.primaryPink)
                        .scaleEffect(0.8)
                    Text("Загрузка тарифов...")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.AppColor.textSecondary)
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
                                        .foregroundStyle(Color.AppColor.textSecondary)
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
                                    .foregroundStyle(Color.AppColor.textPrimary)
                                Text("\(Int(selected.interestRate * 100))% годовых")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.AppColor.textSecondary)
                            }
                        } else {
                            Text("Выберите тариф")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.AppColor.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.AppColor.textSecondary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.AppColor.backgroundMain)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.AppColor.textSecondary.opacity(0.3), lineWidth: 1)
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
                .foregroundStyle(Color.AppColor.primaryDark)

            if viewModel.state.isLoading {
                ProgressView()
                    .tint(Color.AppColor.primaryPink)
                    .padding(.top, 8)
            } else if viewModel.state.loans.isEmpty {
                Text("У вас пока нет кредитов")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.AppColor.textSecondary)
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
        .background(Color.AppColor.primaryWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    func loanRow(_ loan: CreditResponse) -> some View {
        Button {
            viewModel.selectLoan(loanId: loan.loanId)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(loan.tariffName ?? "Кредит")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.AppColor.textPrimary)

                    Spacer()

                    Text(loan.isActive ? "Активен" : "Закрыт")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(loan.isActive ? Color.AppColor.textSuccess : Color.AppColor.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill((loan.isActive ? Color.AppColor.textSuccess : Color.AppColor.textSecondary).opacity(0.1))
                        )
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Сумма")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.AppColor.textSecondary)
                        Text(formatMoney(loan.initialAmount))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.AppColor.textPrimary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Остаток")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.AppColor.textSecondary)
                        Text(formatMoney(loan.remainingAmount))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(loan.remainingAmount > 0 ? Color.AppColor.textError : Color.AppColor.textSuccess)
                    }
                }
            }
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

    var loanDetailsSheet: some View {
        LoanDetailsSheet(viewModel: viewModel)
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

    // MARK: - Helpers UI

    func amountStepper(title: String, value: Binding<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.AppColor.textSecondary)

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
                    .fill(Color.AppColor.backgroundMain)
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
