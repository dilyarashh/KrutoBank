import Foundation

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
}
