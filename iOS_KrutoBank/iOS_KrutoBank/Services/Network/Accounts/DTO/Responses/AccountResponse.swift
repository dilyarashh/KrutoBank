struct AccountResponse: Decodable {
    let id: String
    let name: String?
    let balance: Double
    let openedAt: String
    let isClosed: Bool
    let closedAt: String?
    let currency: String

    var currencySymbol: String {
        Currency(rawValue: currency)?.symbol ?? currency
    }
}
