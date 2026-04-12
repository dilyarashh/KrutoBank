import Foundation

// MARK: - DTO

struct AccountOperationResponse: Decodable, Sendable {
    let createdAt: String
    let type: OperationTypeDTO
    let amount: Double
}

struct AccountInOperationResponse: Decodable, Sendable {
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
    case transferIn = "TransferIn"
    case transferOut = "TransferOut"
}

// MARK: - Mapper

extension AccountOperationResponse {
    func toDomain() -> AccountOperation {
        AccountOperation(
            createdAt: DateTimeFormatter.parse(createdAt) ?? .now,
            type: type.toDomain(),
            amount: amount
        )
    }
}

private extension OperationTypeDTO {
    func toDomain() -> AccountOperationType {
        switch self {
        case .deposit:
            return .deposit
        case .withdraw:
            return .withdraw
        case .transferIn:
            return .transferIn
        case .transferOut:
            return .transferOut
        }
    }
}
