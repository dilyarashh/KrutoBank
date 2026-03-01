extension AccountsViewModel {
    struct State {
        var isLoading: Bool = false
        var accounts: [UserAccountResponse] = []
        var errorText: String? = nil

        var openAccountName: String = ""

        var isDetailsLoading: Bool = false
        var isDetailsSheetPresented: Bool = false
        var selectedAccountId: String? = nil
        var selectedAccount: AccountResponse? = nil
        var detailsErrorText: String? = nil
        var accountOperations: [AccountOperationResponse]?
        var operationsErrorText: String? = nil

        var isActionLoading: Bool = false
        var amountInput: Double = 1000
    }
}
