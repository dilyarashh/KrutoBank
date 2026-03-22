import Foundation

// MARK: - DTO

struct AccountOperationResponse: Decodable {
    let id: String
    let accountId: String
    let createdAt: String
    let type: OperationTypeDTO
    let amount: Double
    let account: AccountInOperationResponse?
}

struct AccountInOperationResponse: Decodable {
    let id: String
    let name: String?
    let balance: Double?
    let openedAt: String
    let currency: String?
    let isClosed: Bool
    let closedAt: String?
}

enum OperationTypeDTO: String, Decodable {
    case deposit = "Deposit"
    case withdraw = "Withdraw"
}

// MARK: - Mapper

extension AccountOperationResponse {
    func toDomain() -> AccountOperation {
        AccountOperation(
            id: id,
            accountId: accountId,
            createdAt: createdAt,
            type: type.toDomain(),
            amount: amount,
            currency: account?.currency ?? "RUB"
        )
    }
}

private extension OperationTypeDTO {
    func toDomain() -> AccountOperationType {
        switch self {
        case .deposit:  return .deposit
        case .withdraw: return .withdraw
        }
    }
}
