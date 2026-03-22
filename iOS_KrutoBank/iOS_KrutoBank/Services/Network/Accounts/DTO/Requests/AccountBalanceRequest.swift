struct AccountBalanceRequest: Encodable {
    let fromAccountId: String
    let toAccountId: String
    let amount: Double
}
