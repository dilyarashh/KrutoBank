import Foundation

// MARK: - CreditRating DTO

struct CreditRatingResponse: Decodable {
    let userId: String
    let score: Int
    let activeLoans: Int
    let overduePayments: Int
}

// MARK: - CreditRating Mapper

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
