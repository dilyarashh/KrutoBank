import Foundation

// MARK: - DTO

struct CreditResponse: Decodable, Sendable {
    let loanId: String
    let initialAmount: Double
    let remainingAmount: Double
    let tariffName: String?
    let interestRate: Double
    let createdAt: String
    let isActive: Bool
}

// MARK: - Mapper

extension CreditResponse {
    func toDomain() -> Credit {
        Credit(
            loanId: loanId,
            initialAmount: initialAmount,
            remainingAmount: remainingAmount,
            tariffName: tariffName,
            interestRate: interestRate,
            createdAt: createdAt,
            isActive: isActive
        )
    }
}
