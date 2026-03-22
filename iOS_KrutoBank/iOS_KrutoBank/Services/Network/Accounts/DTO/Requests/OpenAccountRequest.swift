struct OpenAccountRequest: Encodable {
    let name: String
    let currency: AccountCurrency
}
