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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let number = formatter.string(from: NSNumber(value: amount)) ?? String(amount)
        return "\(number) \(symbol(for: currency))"
    }
}
