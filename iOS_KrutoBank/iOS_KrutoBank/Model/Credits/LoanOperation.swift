import Foundation

struct LoanOperation: Identifiable {
    let operationId: String
    let amount: Double
    let operationDate: String
    let operationType: String?

    var id: String { operationId }

    var typeDisplayName: String {
        operationType ?? "Неизвестно"
    }

    var formattedAmount: String {
        let formatted = amount.rounded() == amount
            ? String(Int(amount))
            : String(format: "%.2f", amount)
        return "\(formatted) ₽"
    }

    var formattedDate: String {
        Self.parse(operationDate, style: .medium, timeStyle: .none)
    }

    var formattedDateTime: String {
        Self.parse(operationDate, style: .short, timeStyle: .short)
    }

    private static func parse(_ dateString: String, style: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: dateString) else { return dateString }
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = timeStyle
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
