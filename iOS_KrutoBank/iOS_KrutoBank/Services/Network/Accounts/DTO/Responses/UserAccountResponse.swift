struct UserAccountResponse: Decodable, Identifiable {
    let userId: String
    let accountId: String
    let accountName: String
    let balance: Double
    let isClosed: Bool
    let currency: String

    var id: String { accountId }

    var currencySymbol: String {
        Currency(rawValue: currency)?.symbol ?? currency
    }
}
