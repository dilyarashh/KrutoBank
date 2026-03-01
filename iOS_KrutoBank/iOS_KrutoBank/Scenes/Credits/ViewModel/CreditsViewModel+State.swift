extension CreditsViewModel {
    struct State {
        var isLoading: Bool = false
        var isActionLoading: Bool = false
        var errorText: String? = nil

        var userId: String? = nil

        var loans: [CreditResponse] = []
        var tariffs: [TariffResponse] = []
        var selectedLoanId: String? = nil

        var isDetailsSheetPresented: Bool = false
        var detailsErrorText: String? = nil

        var loanOperations: [LoanOperationResponse] = []
        var isOperationsLoading: Bool = false
        var operationsErrorText: String? = nil

        var takeAmount: Double = 10_000
        var repayAmount: Double = 1_000
        var tariffName: String = ""
    }
}
