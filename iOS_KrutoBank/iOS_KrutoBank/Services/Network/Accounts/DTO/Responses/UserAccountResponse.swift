import Foundation

// MARK: - DTO

struct UserAccountResponse: Decodable, Sendable {
    let userId: String
    let accountId: String
    let accountName: String
    let balance: Double
    let currency: AccountCurrency
    let isClosed: Bool
}

// MARK: - Mapper

extension UserAccountResponse {
    func toDomain() -> UserAccount {
        UserAccount(
            id: accountId,
            name: accountName,
            balance: balance,
            currency: currency.rawValue,
            isClosed: isClosed
        )
    }
}
