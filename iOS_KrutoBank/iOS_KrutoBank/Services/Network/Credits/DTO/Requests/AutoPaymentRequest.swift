struct AutoPaymentRequest: Encodable, Sendable {
    let loanId: String
    let accountId: String
    let amount: Double
    let intervalMinutes: Int
}
