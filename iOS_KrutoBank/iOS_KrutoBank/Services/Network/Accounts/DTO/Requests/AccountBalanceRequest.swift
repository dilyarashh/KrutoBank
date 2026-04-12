struct AccountBalanceRequest: Encodable, Sendable {
    let accountId: String
    let amount: Double
}
