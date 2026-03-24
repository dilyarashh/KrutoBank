import Foundation
import SwiftUI

struct AccountOperation: Identifiable {
    let createdAt: Date
    let type: AccountOperationType
    let amount: Double
    let currency: String = "RUB"

    var id: String { "\(createdAt.timeIntervalSince1970)-\(type.displayedName)-\(amount)" }

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
        case .transferIn:
            return "+\(number) \(currencySymbol)"
        case .transferOut:
            return "-\(number) \(currencySymbol)"
        }
    }
}

enum AccountOperationType {
    case deposit
    case withdraw
    case transferIn
    case transferOut

    var displayedName: String {
        switch self {
        case .deposit:
            return "Пополнение"
        case .withdraw:
            return "Снятие"
        case .transferIn:
            return "Входящий перевод"
        case .transferOut:
            return "Исходящий перевод"
        }
    }

    var iconName: String {
        switch self {
        case .deposit:
            return "arrow.down.circle.fill"
        case .withdraw:
            return "arrow.up.circle.fill"
        case .transferIn:
            return "arrow.down.circle.fill"
        case .transferOut:
            return "arrow.up.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .deposit:
            return Color.green
        case .withdraw:
            return Color.red
        case .transferIn:
            return Color.green
        case .transferOut:
            return Color.red
        }
    }
}
