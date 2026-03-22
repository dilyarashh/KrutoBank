import Foundation
import SwiftUI
import Combine

protocol CreditsViewModelDelegate: AnyObject {
    func creditsViewModelDidRequestShowLoanOperations(
        _ viewModel: CreditsViewModel,
        userId: String,
        loanId: String
    )
}

@MainActor
final class CreditsViewModel: ObservableObject {
    weak var delegate: CreditsViewModelDelegate?

    @DIInject(\.creditsRepository, container: DI.container)
    private var creditsRepository: CreditsRepositoryProtocol

    @DIInject(\.usersRepository, container: DI.container)
    private var usersRepository: UsersRepositoryProtocol

    private let toastStore = ToastStore.shared

    @Published var state = State()

    var selectedTariffId: String? {
        didSet {
            if let tariffId = selectedTariffId,
               let tariff = state.tariffs.first(where: { $0.id == tariffId }) {
                state.tariffName = tariff.name
            }
        }
    }

    // MARK: - Lifecycle

    func load() {
        state.errorText = nil
        state.isLoading = true

        Task {
            do {
                let user = try await usersRepository.getMyInfo()
                state.userId = user.id

                async let loansTask = creditsRepository.getLoans(with: user.id)
                async let tariffsTask = creditsRepository.getTariffs()

                let (loans, tariffs) = try await (loansTask, tariffsTask)
                state.loans = loans
                state.tariffs = tariffs
                state.isLoading = false

                // Load rating & overdue in background
                loadCreditRatingAndOverdue(userId: user.id)
            } catch {
                state.isLoading = false
                state.errorText = AppStrings.Common.error
                toastStore.showError(error)
            }
        }
    }

    func loadCreditRatingAndOverdue(userId: String) {
        state.isRatingLoading = true
        Task {
            async let overdueTask = creditsRepository.getOverduePayments(userId: userId)
            async let ratingTask = creditsRepository.getCreditRating(userId: userId)
            do {
                let (overdue, rating) = try await (overdueTask, ratingTask)
                state.overduePayments = overdue
                state.creditRating = rating
                state.isRatingLoading = false
            } catch {
                state.isRatingLoading = false
                state.ratingErrorText = "Не удалось загрузить кредитный рейтинг"
            }
        }
    }

    // MARK: - Selection / Sheet

    func selectLoan(loanId: String) {
        state.selectedLoanId = loanId
        state.isDetailsSheetPresented = true
        loadLoanHistory()
    }

    func dismissDetails() {
        state.isDetailsSheetPresented = false
        state.selectedLoanId = nil
        state.detailsErrorText = nil
        state.loanOperations = []
        state.operationsErrorText = nil
    }

    var selectedLoan: CreditResponse? {
        guard let selectedLoanId = state.selectedLoanId else { return nil }
        return state.loans.first { $0.loanId == selectedLoanId }
    }

    // MARK: - Actions

    func takeLoan() {
        guard let userId = state.userId, !state.tariffName.isEmpty else { return }
        state.errorText = nil
        state.isActionLoading = true
        let request = TakeLoanRequest(userId: userId, tariffName: state.tariffName, amount: state.takeAmount)

        Task {
            do {
                try await creditsRepository.takeLoan(with: request)
                state.isActionLoading = false
                selectedTariffId = nil
                state.tariffName = ""
                state.takeAmount = 10_000
                toastStore.show(.success("Кредит оформлен"))
                await reloadLoans()
            } catch {
                state.isActionLoading = false
                state.errorText = AppStrings.Common.error
                toastStore.showError(error)
            }
        }
    }

    func repaySelectedLoan() {
        guard let selectedLoanId = state.selectedLoanId,
              let selectedLoan = selectedLoan else { return }

        guard state.repayAmount <= selectedLoan.remainingAmount else {
            state.detailsErrorText = "Сумма погашения не может превышать остаток"
            return
        }
        state.detailsErrorText = nil
        state.isActionLoading = true
        let request = RepayLoanRequest(loanId: selectedLoanId, amount: state.repayAmount)

        Task {
            do {
                try await creditsRepository.repayLoan(with: request)
                state.isActionLoading = false
                state.repayAmount = 1_000
                toastStore.show(.success("Платёж по кредиту выполнен"))
                await reloadLoans(keepSelection: true)
                loadLoanHistory()
            } catch {
                state.isActionLoading = false
                state.detailsErrorText = AppStrings.Common.error
                toastStore.showError(error)
            }
        }
    }

    func getTariffs() {
        Task {
            do {
                let tariffs = try await creditsRepository.getTariffs()
                state.tariffs = tariffs
            } catch {
                state.detailsErrorText = AppStrings.Common.error
            }
        }
    }

    func loadLoanHistory() {
        guard let userId = state.userId, let loanId = state.selectedLoanId else { return }
        state.isOperationsLoading = true
        state.operationsErrorText = nil

        Task {
            do {
                let operations = try await creditsRepository.getLoanHistory(with: userId, loanId: loanId)
                state.loanOperations = operations.sorted { $0.operationDate > $1.operationDate }
                state.isOperationsLoading = false
            } catch {
                state.isOperationsLoading = false
                state.operationsErrorText = AppStrings.Common.error
            }
        }
    }

    // MARK: - Validation

    var canTakeLoan: Bool { !state.tariffName.isEmpty && state.takeAmount > 0 }

    var canRepayLoan: Bool {
        guard let selectedLoan = selectedLoan else { return false }
        return state.repayAmount > 0 && state.repayAmount <= selectedLoan.remainingAmount && !state.isActionLoading
    }

    // MARK: - Helpers

    private func reloadLoans(keepSelection: Bool = false) async {
        guard let userId = state.userId else { return }
        do {
            let loans = try await creditsRepository.getLoans(with: userId)
            state.loans = loans
            if keepSelection, let selectedLoanId = state.selectedLoanId {
                if !loans.contains(where: { $0.loanId == selectedLoanId }) {
                    state.selectedLoanId = nil
                    state.isDetailsSheetPresented = false
                }
            }
        } catch {
            state.errorText = AppStrings.Common.error
        }
    }
}
