import Foundation

final class CreditsRepository: CreditsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getTariffs() async throws -> [Tariff] {
        let response = try await networkService.requestDecodable(GetTariffs(), as: [TariffResponse].self)
        return response.map { $0.toDomain() }
    }

    func getLoans(with userId: String) async throws -> [Credit] {
        let response = try await networkService.requestDecodable(GetLoansEndPoint(userId: userId), as: [CreditResponse].self)
        return response.map { $0.toDomain() }
    }

    func getLoanHistory(with userId: String, loanId: String) async throws -> [LoanOperation] {
        let response = try await networkService.requestDecodable(
            GetLoanHistoryEndPoint(userId: userId, loanId: loanId),
            as: [LoanOperationResponse].self
        )
        return response.map { $0.toDomain() }
    }

    func takeLoan(with request: TakeLoanRequest) async throws {
        try await networkService.request(TakeLoanEndPoint(body: request))
    }

    func repayLoan(with request: RepayLoanRequest) async throws {
        try await networkService.request(RepayLoanEndPoint(body: request))
    }

    func getCreditRating(userId: String) async throws -> CreditRating {
        let response = try await networkService.requestDecodable(
            GetCreditRatingEndPoint(userId: userId),
            as: CreditRatingResponse.self
        )
        return response.toDomain()
    }

    func setAutoPayment(with request: AutoPaymentRequest) async throws {
        try await networkService.request(AutoPaymentEndPoint(body: request))
    }
}
