import Foundation

// MARK: - DTO

struct LoanOperationResponse: Decodable {
    let operationId: String
    let amount: Double
    let operationDate: String
    let operationType: String?
}

// MARK: - Mapper

extension LoanOperationResponse {
    func toDomain() -> LoanOperation {
        LoanOperation(
            operationId: operationId,
            amount: amount,
            operationDate: operationDate,
            operationType: operationType
        )
    }
}
