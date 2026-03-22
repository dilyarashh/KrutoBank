import Foundation
import SwiftUI

// MARK: - Domain Model

struct LoanOperation: Identifiable {
    let operationId: String
    let amount: Double
    let operationDate: String
    let operationType: String?

    var id: String { operationId }

    var typeDisplayName: String { operationType ?? "Неизвестно" }

    var formattedAmount: String {
        "\(CurrencyFormatter.formatMoney(amount)) ₽"
    }

    var formattedDate: String {
        DateTimeFormatter.format(operationDate, dateStyle: .medium, timeStyle: .none)
    }

    var formattedDateTime: String {
        DateTimeFormatter.format(operationDate, dateStyle: .short, timeStyle: .short)
    }

    var iconName: String {
        switch operationType?.lowercased() {
        case "payment", "погашение": return "arrow.down.circle.fill"
        case "accrual", "начисление": return "exclamationmark.circle.fill"
        case "issuance", "выдача": return "arrow.up.circle.fill"
        default: return "creditcard.fill"
        }
    }

    var iconColor: Color {
        switch operationType?.lowercased() {
        case "payment", "погашение": return Color.AppColor.primaryPink
        case "accrual", "начисление": return Color.orange
        case "issuance", "выдача": return Color.green
        default: return Color.AppColor.textSecondary
        }
    }
}
