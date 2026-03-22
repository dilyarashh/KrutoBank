import Foundation

// MARK: - Domain Model

struct AccountOperation: Identifiable {
    let id: String
    let accountId: String
    let createdAt: String
    let type: AccountOperationType
    let amount: Double
    let currency: String

    var currencySymbol: String { CurrencyFormatter.symbol(for: currency) }

    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: createdAt) else { return createdAt }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = amount.rounded() == amount ? 0 : 2
        let number = formatter.string(from: NSNumber(value: amount)) ?? String(amount)
        switch type {
        case .deposit:  return "+\(number) \(currencySymbol)"
        case .withdraw: return "-\(number) \(currencySymbol)"
        }
    }
}

enum AccountOperationType {
    case deposit
    case withdraw
}
