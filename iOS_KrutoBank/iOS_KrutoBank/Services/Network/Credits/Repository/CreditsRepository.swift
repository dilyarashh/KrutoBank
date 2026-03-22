import Foundation

final class CreditsRepository: CreditsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getTariffs() async throws -> [TariffResponse] {
        return try await networkService.requestDecodable(GetTariffs(), as: [TariffResponse].self)
    }

    func getLoans(with userId: String) async throws -> [CreditResponse] {
        return try await networkService.requestDecodable(GetLoansEndPoint(userId: userId), as: [CreditResponse].self)
    }

    func getLoanHistory(with userId: String, loanId: String) async throws -> [LoanOperationResponse] {
        return try await networkService.requestDecodable(
            GetLoanHistoryEndPoint(userId: userId, loanId: loanId),
            as: [LoanOperationResponse].self
        )
    }

    func takeLoan(with request: TakeLoanRequest) async throws {
        try await networkService.request(TakeLoanEndPoint(body: request))
    }

    func repayLoan(with request: RepayLoanRequest) async throws {
        try await networkService.request(RepayLoanEndPoint(body: request))
    }

    func getOverduePayments(userId: String) async throws -> [OverduePaymentResponse] {
        return try await networkService.requestDecodable(
            GetOverduePaymentsEndPoint(userId: userId),
            as: [OverduePaymentResponse].self
        )
    }

    func getCreditRating(userId: String) async throws -> CreditRatingResponse {
        return try await networkService.requestDecodable(
            GetCreditRatingEndPoint(userId: userId),
            as: CreditRatingResponse.self
        )
    }
}
