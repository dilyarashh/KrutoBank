extension AccountsViewModel {
    struct State {
        var isLoading: Bool = false
        var accounts: [UserAccount] = []
        var errorText: String? = nil

        var openAccountName: String = ""
        var selectedCurrency: AccountCurrency = .rub

        var isDetailsLoading: Bool = false
        var isDetailsSheetPresented: Bool = false
        var selectedAccountId: String? = nil
        var selectedAccount: Account? = nil
        var detailsErrorText: String? = nil
        var accountOperations: [AccountOperation]?
        var operationsErrorText: String? = nil

        var isActionLoading: Bool = false
        var amountInput: Double = 1000

        var transferTargetAccountId: String = ""
        var transferAmount: Double = 1000
        var transferError: String? = nil

        var showHiddenAccounts: Bool = false
    }
}
