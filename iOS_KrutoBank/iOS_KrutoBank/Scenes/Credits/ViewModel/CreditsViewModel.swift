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

    @Published
    var state = State()

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
            } catch {
                state.isLoading = false
                state.errorText = AppStrings.Common.error
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
        guard let userId = state.userId else { return }
        guard !state.tariffName.isEmpty else { return }

        state.errorText = nil
        state.isActionLoading = true

        let request = TakeLoanRequest(
            userId: userId,
            tariffName: state.tariffName,
            amount: state.takeAmount
        )

        Task {
            do {
                try await creditsRepository.takeLoan(with: request)

                await MainActor.run {
                    state.isActionLoading = false
                    selectedTariffId = nil
                    state.tariffName = ""
                    state.takeAmount = 10_000
                }

                await reloadLoans()
            } catch {
                await MainActor.run {
                    state.isActionLoading = false
                    state.errorText = AppStrings.Common.error
                }
            }
        }
    }

    func repaySelectedLoan() {
        guard let selectedLoanId = state.selectedLoanId else { return }
        guard let selectedLoan = selectedLoan else { return }

        guard state.repayAmount <= selectedLoan.remainingAmount else {
            state.detailsErrorText = "Сумма погашения не может превышать остаток"
            return
        }

        state.detailsErrorText = nil
        state.isActionLoading = true

        let request = RepayLoanRequest(
            loanId: selectedLoanId,
            amount: state.repayAmount
        )

        Task {
            do {
                try await creditsRepository.repayLoan(with: request)

                await MainActor.run {
                    state.isActionLoading = false
                    state.repayAmount = 1_000
                }

                await reloadLoans(keepSelection: true)
                loadLoanHistory()
            } catch {
                await MainActor.run {
                    state.isActionLoading = false
                    state.detailsErrorText = AppStrings.Common.error
                }
            }
        }
    }

    func getTariffs() {
        Task {
            do {
                let tariffs = try await creditsRepository.getTariffs()
                await MainActor.run {
                    state.tariffs = tariffs
                }
            } catch {
                await MainActor.run {
                    state.detailsErrorText = AppStrings.Common.error
                }
            }
        }
    }

    func showLoanHistory() {
        loadLoanHistory()
    }

    func loadLoanHistory() {
        guard let userId = state.userId,
              let loanId = state.selectedLoanId else { return }

        state.isOperationsLoading = true
        state.operationsErrorText = nil

        Task {
            do {
                let operations = try await creditsRepository.getLoanHistory(with: userId, loanId: loanId)

                let sortedOperations = operations.sorted {
                    $0.operationDate > $1.operationDate
                }

                await MainActor.run {
                    state.loanOperations = sortedOperations
                    state.isOperationsLoading = false
                }
            } catch {
                await MainActor.run {
                    state.isOperationsLoading = false
                    state.operationsErrorText = AppStrings.Common.error
                }
            }
        }
    }

    // MARK: - Validation

    var canTakeLoan: Bool {
        !state.tariffName.isEmpty && state.takeAmount > 0
    }

    var canRepayLoan: Bool {
        guard let selectedLoan = selectedLoan else { return false }
        return state.repayAmount > 0 &&
        state.repayAmount <= selectedLoan.remainingAmount &&
        !state.isActionLoading
    }

    // MARK: - Helpers

    private func reloadLoans(keepSelection: Bool = false) async {
        guard let userId = state.userId else { return }

        do {
            let loans = try await creditsRepository.getLoans(with: userId)

            await MainActor.run {
                state.loans = loans

                if keepSelection, let selectedLoanId = state.selectedLoanId {
                    let stillExists = loans.contains { $0.loanId == selectedLoanId }
                    if !stillExists {
                        state.selectedLoanId = nil
                        state.isDetailsSheetPresented = false
                    }
                }
            }
        } catch {
            await MainActor.run {
                state.errorText = AppStrings.Common.error
            }
        }
    }
}
