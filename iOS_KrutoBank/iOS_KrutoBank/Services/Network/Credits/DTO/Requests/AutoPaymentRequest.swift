struct AutoPaymentRequest: Encodable {
    let loanId: String
    let accountId: String
    let amount: Double
    let intervalMinutes: Int
}
