import Foundation

enum CurrencyFormatter {
    static func symbol(for currency: String) -> String {
        switch currency {
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        default:    return currency
        }
    }

    static func formatted(amount: Double, currency: String) -> String {
        let number = formatNumber(amount, minFraction: 2, maxFraction: 2)
        return "\(number) \(symbol(for: currency))"
    }

    static func formatMoney(_ value: Double) -> String {
        value.rounded() == value
            ? String(Int(value))
            : String(format: "%.2f", value)
    }

    static func formatNumber(_ value: Double, minFraction: Int = 0, maxFraction: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.minimumFractionDigits = minFraction
        formatter.maximumFractionDigits = maxFraction
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}

// MARK: - Date

enum DateTimeFormatter {
    static func format(_ dateString: String, dateStyle: DateFormatter.Style = .short, timeStyle: DateFormatter.Style = .short) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = iso.date(from: dateString) else { return dateString }
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
