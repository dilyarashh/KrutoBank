import Foundation

// MARK: - DTO

struct CreditRatingResponse: Decodable {
    let userId: String
    let score: Int
    let activeLoans: Int
    let overduePayments: Int
}

// MARK: - Mapper

extension CreditRatingResponse {
    func toDomain() -> CreditRating {
        CreditRating(
            userId: userId,
            score: score,
            activeLoans: activeLoans,
            overduePayments: overduePayments
        )
    }
}
