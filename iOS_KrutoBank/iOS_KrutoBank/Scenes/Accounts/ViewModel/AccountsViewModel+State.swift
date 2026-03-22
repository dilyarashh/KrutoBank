extension AccountsViewModel {
    struct State {
        var isLoading: Bool = false
        var accounts: [UserAccountResponse] = []
        var errorText: String? = nil

        // Open account form
        var openAccountName: String = ""
        var selectedCurrency: Currency = .rub

        // Account details sheet
        var isDetailsLoading: Bool = false
        var isDetailsSheetPresented: Bool = false
        var selectedAccountId: String? = nil
        var selectedAccount: AccountResponse? = nil
        var detailsErrorText: String? = nil
        var accountOperations: [AccountOperationResponse]?
        var operationsErrorText: String? = nil

        // Deposit/Withdraw
        var isActionLoading: Bool = false
        var amountInput: Double = 1000

        // Transfer
        var transferTargetAccountId: String = ""
        var transferAmount: Double = 1000
        var transferError: String? = nil

        // Hidden accounts
        var showHiddenAccounts: Bool = false
    }
}
