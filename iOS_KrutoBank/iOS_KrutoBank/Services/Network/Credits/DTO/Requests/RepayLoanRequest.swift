struct RepayLoanRequest: Encodable {
    let loanId: String
    let amount: Double
    let accountId: String
}
