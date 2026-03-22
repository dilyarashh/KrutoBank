import Foundation

// MARK: - DTO

struct UserAccountResponse: Decodable {
    let id: String
    let name: String?
    let balance: Double
    let currency: AccountCurrency
    let openedAt: String
    let isClosed: Bool
    let closedAt: String?
}

// MARK: - Currency Enum

enum AccountCurrency: String, Codable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
}

// MARK: - Mapper

extension UserAccountResponse {
    func toDomain() -> UserAccount {
        UserAccount(
            id: id,
            name: name ?? "",
            balance: balance,
            currency: currency.rawValue,
            openedAt: openedAt,
            isClosed: isClosed,
            closedAt: closedAt
        )
    }
}
