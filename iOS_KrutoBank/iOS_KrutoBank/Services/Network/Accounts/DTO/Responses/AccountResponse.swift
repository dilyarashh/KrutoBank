import Foundation

// MARK: - DTO

struct AccountResponse: Decodable {
    let userId: String
    let accountId: String
    let accountName: String
    let balance: Double
    let currency: AccountCurrency
    let isClosed: Bool
}

// MARK: - Mapper

extension AccountResponse {
    func toDomain() -> Account {
        Account(
            id: accountId,
            userId: userId,
            name: accountName,
            balance: balance,
            currency: currency.rawValue,
            isClosed: isClosed
        )
    }
}
