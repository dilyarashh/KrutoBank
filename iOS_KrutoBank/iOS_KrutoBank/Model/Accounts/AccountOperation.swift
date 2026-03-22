import Foundation

struct AccountOperation: Identifiable {
    let id: String
    let accountId: String
    let createdAt: String
    let type: AccountOperationType
    let amount: Double
    let currency: String

    var currencySymbol: String {
        CurrencyFormatter.symbol(for: currency)
    }

    var formattedDate: String {
        DateTimeFormatter.format(createdAt, dateStyle: .short, timeStyle: .short)
    }

    var formattedAmount: String {
        let number = CurrencyFormatter.formatNumber(
            amount,
            minFraction: amount.rounded() == amount ? 0 : 2,
            maxFraction: 2
        )
        switch type {
        case .deposit: 
            return "+\(number) \(currencySymbol)"
        case .withdraw: 
            return "-\(number) \(currencySymbol)"
        }
    }
}

enum AccountOperationType {
    case deposit
    case withdraw
}
