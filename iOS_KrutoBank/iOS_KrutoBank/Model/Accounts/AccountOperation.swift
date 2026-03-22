import Foundation
import SwiftUI

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

    var displayedName: String {
        switch self {
        case .deposit: 
            return "Пополнение"
        case .withdraw:
            return "Снятие"
        }
    }

    var iconName: String {
        switch self {
        case .deposit: 
            return "arrow.down.circle.fill"
        case .withdraw:
            return "arrow.up.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .deposit: 
            return Color.green
        case .withdraw:
            return Color.red
        }
    }
}
