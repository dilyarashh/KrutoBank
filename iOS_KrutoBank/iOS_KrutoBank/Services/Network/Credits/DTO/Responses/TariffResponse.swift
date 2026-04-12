import Foundation

// MARK: - DTO

struct TariffResponse: Decodable, Sendable {
    let id: String
    let name: String
    let interestRate: Double
}

// MARK: - Mapper

extension TariffResponse {
    func toDomain() -> Tariff {
        Tariff(
            id: id,
            name: name,
            interestRate: interestRate
        )
    }
}
