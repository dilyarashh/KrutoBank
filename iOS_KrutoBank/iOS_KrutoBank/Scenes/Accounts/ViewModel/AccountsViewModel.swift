import Foundation
import SwiftUI
import Combine

protocol AccountsViewModelDelegate: AnyObject {
    func accountsViewModelDidRequestShowOperations(
        _ viewModel: AccountsViewModel,
        accountId: String
    )
}

@MainActor
final class AccountsViewModel: ObservableObject {
    weak var delegate: AccountsViewModelDelegate?

    @DIInject(\.accountsRepository, container: DI.container)
    private var accountsRepository: AccountsRepositoryProtocol

    @Published
    var state = State()

    // MARK: - Lifecycle

    func load() {
        state.errorText = nil
        state.isLoading = true

        Task {
            do {
                let accounts = try await accountsRepository.getMyAccounts()
                state.accounts = accounts
                state.isLoading = false
            } catch {
                state.isLoading = false
                state.errorText = AppStrings.Common.error
            }
        }
    }

    // MARK: - Selection

    func selectAccount(accountId: String) {
        state.selectedAccountId = accountId
        state.isDetailsSheetPresented = true
        state.accountOperations = nil
        state.detailsErrorText = nil
        state.operationsErrorText = nil

        loadAccountData()
    }

    func dismissDetails() {
        state.isDetailsSheetPresented = false
        state.selectedAccountId = nil
        state.selectedAccount = nil
        state.accountOperations = nil
        state.detailsErrorText = nil
        state.operationsErrorText = nil
        state.isDetailsLoading = false
    }

    func loadAccountData() {
        guard let accountId = state.selectedAccountId else { return }

        state.isDetailsLoading = true
        state.detailsErrorText = nil
        state.operationsErrorText = nil

        Task {
            async let accountTask = accountsRepository.getMyAccount(with: accountId)
            async let operationsTask = accountsRepository.getMyOperations(with: accountId)

            do {
                let (account, operations) = try await (accountTask, operationsTask)

                await MainActor.run {
                    state.selectedAccount = account
                    state.accountOperations = operations
                    state.isDetailsLoading = false
                }
            } catch {
                await MainActor.run {
                    state.isDetailsLoading = false
                    state.detailsErrorText = AppStrings.Common.error
                    state.operationsErrorText = AppStrings.Common.error
                }
            }
        }
    }

    func reloadAccountDataAfterOperation() {
        guard let accountId = state.selectedAccountId else { return }

        Task {
            async let accountTask = accountsRepository.getMyAccount(with: accountId)
            async let operationsTask = accountsRepository.getMyOperations(with: accountId)

            do {
                let (account, operations) = try await (accountTask, operationsTask)

                await MainActor.run {
                    state.selectedAccount = account
                    state.accountOperations = operations
                }
            } catch {
                await MainActor.run {
                    state.detailsErrorText = AppStrings.Common.error
                }
            }
        }
    }

    // MARK: - Actions

    func openAccount() {
        state.errorText = nil
        state.isActionLoading = true

        let name = state.openAccountName.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            do {
                try await accountsRepository.openAccount(with: name)
                state.isActionLoading = false
                await reloadAccountsAfterChange(keepSelection: false)
                state.openAccountName = ""
            } catch {
                state.isActionLoading = false
                state.errorText = AppStrings.Common.error
            }
        }
    }

    func closeSelectedAccount() {
        guard let accountId = state.selectedAccountId else { return }

        state.detailsErrorText = nil
        state.isActionLoading = true

        Task {
            do {
                try await accountsRepository.closeAccount(with: accountId)
                state.isActionLoading = false
                await reloadAccountsAfterChange(keepSelection: false)
                dismissDetails()
            } catch {
                state.isActionLoading = false
                state.detailsErrorText = AppStrings.Common.error
            }
        }
    }

    func depositSelectedAccount() {
        guard let accountId = state.selectedAccountId else { return }

        state.detailsErrorText = nil
        state.isActionLoading = true

        let amount = state.amountInput

        Task {
            do {
                try await accountsRepository.depositAccount(with: accountId, amount: amount)
                state.isActionLoading = false
                await reloadAccountsAfterChange(keepSelection: true)
                await reloadAccountDataAfterOperation()
            } catch {
                state.isActionLoading = false
                state.detailsErrorText = AppStrings.Common.error
            }
        }
    }

    func withdrawSelectedAccount() {
        guard let accountId = state.selectedAccountId else { return }

        state.detailsErrorText = nil
        state.isActionLoading = true

        let amount = state.amountInput

        Task {
            do {
                try await accountsRepository.withdrawFromAccount(with: accountId, amount: amount)
                state.isActionLoading = false
                await reloadAccountsAfterChange(keepSelection: true)
                await reloadAccountDataAfterOperation()
            } catch {
                state.isActionLoading = false
                state.detailsErrorText = AppStrings.Common.error
            }
        }
    }

    func showOperations() {
        guard let accountId = state.selectedAccountId else { return }
        delegate?.accountsViewModelDidRequestShowOperations(self, accountId: accountId)
    }

    // MARK: - Helpers

    private func reloadAccountsAfterChange(keepSelection: Bool) async {
        do {
            let accounts = try await accountsRepository.getMyAccounts()
            state.accounts = accounts

            if keepSelection, state.isDetailsSheetPresented {
                loadAccountData()
            }
        } catch {
            state.errorText = AppStrings.Common.error
        }
    }
}
