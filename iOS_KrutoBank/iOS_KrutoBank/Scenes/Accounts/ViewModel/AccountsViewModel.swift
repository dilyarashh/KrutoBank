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

    @DIInject(\.accountOperationsWebSocket, container: DI.container)
    private var webSocket: AccountOperationsWebSocketProtocol

    private let themeManager = ThemeManager.shared
    private let toastStore = ToastStore.shared

    @Published var state = State()

    var webSocketConnected: Bool { webSocket.isConnected }

    var visibleAccounts: [UserAccount] {
        if state.showHiddenAccounts {
            return state.accounts
        }
        return state.accounts.filter { !themeManager.isHidden($0.id) }
    }

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
                toastStore.showError(error)
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
        state.transferTargetAccountId = ""
        state.transferAmount = 1000

        loadAccountData()
        connectWebSocket(accountId: accountId)
    }

    func dismissDetails() {
        state.isDetailsSheetPresented = false
        state.selectedAccountId = nil
        state.selectedAccount = nil
        state.accountOperations = nil
        state.detailsErrorText = nil
        state.operationsErrorText = nil
        state.isDetailsLoading = false
        webSocket.disconnect()
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
                state.selectedAccount = account
                state.accountOperations = operations
                state.isDetailsLoading = false
            } catch {
                state.isDetailsLoading = false
                state.detailsErrorText = AppStrings.Common.error
                state.operationsErrorText = AppStrings.Common.error
                toastStore.showError(error)
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
                state.selectedAccount = account
                state.accountOperations = operations
            } catch {
                state.detailsErrorText = AppStrings.Common.error
            }
        }
    }

    // MARK: - WebSocket (push-invalidation)

    private func connectWebSocket(accountId: String) {
        webSocket.onInvalidate = { [weak self] in
            self?.reloadAccountDataAfterOperation()
        }
        webSocket.onError = { _ in }
        webSocket.connect(accountId: accountId)
    }

    // MARK: - Actions

    func openAccount() {
        state.errorText = nil
        state.isActionLoading = true
        let name = state.openAccountName.trimmingCharacters(in: .whitespacesAndNewlines)
        let currency = state.selectedCurrency.rawValue

        Task {
            do {
                try await accountsRepository.openAccount(data: .init(name: name, currency: AccountCurrency(rawValue: currency) ?? .rub))
                state.isActionLoading = false
                toastStore.show(.success("Счёт открыт"))
                await reloadAccountsAfterChange(keepSelection: false)
                state.openAccountName = ""
            } catch {
                state.isActionLoading = false
                state.errorText = AppStrings.Common.error
                toastStore.showError(error)
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
                toastStore.show(.success("Счёт закрыт"))
                await reloadAccountsAfterChange(keepSelection: false)
                dismissDetails()
            } catch {
                state.isActionLoading = false
                state.detailsErrorText = AppStrings.Common.error
                toastStore.showError(error)
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
                // TODO: поправить логику перевода средств со счета на счет
                try await accountsRepository.depositAccount(data: .init(fromAccountId: accountId, toAccountId: accountId, amount: amount))
                state.isActionLoading = false
                toastStore.show(.success("Пополнение выполнено"))
                await reloadAccountsAfterChange(keepSelection: true)
                await reloadAccountDataAfterOperation()
            } catch {
                state.isActionLoading = false
                state.detailsErrorText = AppStrings.Common.error
                toastStore.showError(error)
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
                try await accountsRepository.withdrawFromAccount(data: .init(fromAccountId: accountId, toAccountId: accountId, amount: amount))
                state.isActionLoading = false
                toastStore.show(.success("Списание выполнено"))
                await reloadAccountsAfterChange(keepSelection: true)
                await reloadAccountDataAfterOperation()
            } catch {
                state.isActionLoading = false
                state.detailsErrorText = AppStrings.Common.error
                toastStore.showError(error)
            }
        }
    }

    func transferFromSelectedAccount() {
        guard let fromId = state.selectedAccountId else { return }
        let toId = state.transferTargetAccountId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !toId.isEmpty else {
            state.transferError = "Укажите ID счёта получателя"
            return
        }
        state.transferError = nil
        state.isActionLoading = true
        let amount = state.transferAmount
        let currency = state.selectedAccount?.currency ?? "RUB"

        Task {
            do {
                try await accountsRepository.transferMoney(data: .init(fromAccountId: fromId, toPhone: toId, amount: amount))
                state.isActionLoading = false
                toastStore.show(.success("Перевод выполнен"))
                state.transferTargetAccountId = ""
                await reloadAccountsAfterChange(keepSelection: true)
                await reloadAccountDataAfterOperation()
            } catch {
                state.isActionLoading = false
                state.transferError = AppError.from(error).errorDescription
                toastStore.showError(error)
            }
        }
    }

    // MARK: - Hidden accounts

    func toggleHidden(accountId: String) {
        themeManager.toggleHidden(accountId: accountId)
        toastStore.show(.info(themeManager.isHidden(accountId) ? "Счёт скрыт" : "Счёт отображается"))
    }

    func isHidden(_ accountId: String) -> Bool {
        themeManager.isHidden(accountId)
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
