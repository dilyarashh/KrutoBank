import Foundation

enum Currency: String, CaseIterable, Codable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"

    var symbol: String {
        switch self {
        case .rub: return "₽"
        case .usd: return "$"
        case .eur: return "€"
        }
    }

    var displayName: String {
        switch self {
        case .rub: return "Рубль (₽)"
        case .usd: return "Доллар ($)"
        case .eur: return "Евро (€)"
        }
    }
}
