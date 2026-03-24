import Foundation

// MARK: - DTO

struct AccountResponse: Decodable {
    let id: String
    let name: String
    let balance: Double
    let currency: AccountCurrency
    let isClosed: Bool
    let closedAt: String?
}

// MARK: - Mapper

extension AccountResponse {
    func toDomain() -> Account {
        Account(
            id: id,
            name: name,
            balance: balance,
            currency: currency.rawValue,
            isClosed: isClosed,
            closedAt: closedAt
        )
    }
}
