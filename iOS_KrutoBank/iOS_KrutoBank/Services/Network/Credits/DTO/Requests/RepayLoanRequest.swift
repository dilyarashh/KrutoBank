struct RepayLoanRequest: Encodable, Sendable {
    let loanId: String
    let amount: Double
    let accountId: String
}
