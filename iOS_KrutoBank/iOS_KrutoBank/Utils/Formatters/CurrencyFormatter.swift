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
    static func format(
        _ date: Date,
        dateStyle: Foundation.DateFormatter.Style = .short,
        timeStyle: Foundation.DateFormatter.Style = .short
    ) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }

    static func format(
        _ dateString: String,
        dateStyle: Foundation.DateFormatter.Style = .short,
        timeStyle: Foundation.DateFormatter.Style = .short
    ) -> String {
        guard let date = parse(dateString) else { return dateString }
        return format(date, dateStyle: dateStyle, timeStyle: timeStyle)
    }

    static func parse(_ value: String) -> Date? {
        if let date = iso8601WithFractionalSeconds.date(from: value) {
            return date
        }

        if let date = iso8601.date(from: value) {
            return date
        }

        if let date = ruFormatter.date(from: value) {
            return date
        }

        return nil
    }

    private static let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let ruFormatter: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return formatter
    }()
}
