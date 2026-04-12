struct OpenAccountRequest: Encodable, Sendable {
    let name: String
    let currency: AccountCurrency
}
