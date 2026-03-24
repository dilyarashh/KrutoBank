import Foundation

struct UserAccount: Identifiable {
    let id: String
    let name: String
    let balance: Double
    let currency: String
    let isClosed: Bool

    var currencySymbol: String {
        CurrencyFormatter.symbol(for: currency)
    }
    var formattedBalance: String {
        CurrencyFormatter.formatted(amount: balance, currency: currency)
    }
}
