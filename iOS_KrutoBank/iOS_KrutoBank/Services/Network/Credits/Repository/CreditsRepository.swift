import Foundation

final class CreditsRepository: CreditsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getTariffs() async throws -> [TariffResponse] {
        let endPoint = GetTariffs()

        return try await networkService.requestDecodable(
            endPoint,
            as: [TariffResponse].self
        )
    }

    func getLoans(with userId: String) async throws -> [CreditResponse] {
        let endPoint = GetLoansEndPoint(userId: userId)

        return try await networkService.requestDecodable(
            endPoint,
            as: [CreditResponse].self
        )
    }

    func getLoanHistory(with userId: String, loanId: String) async throws -> [LoanOperationResponse] {
        let endPoint = GetLoanHistoryEndPoint(userId: userId, loanId: loanId)

        return try await networkService.requestDecodable(
            endPoint,
            as: [LoanOperationResponse].self
        )
    }

    func takeLoan(with request: TakeLoanRequest) async throws {
        let endPoint = TakeLoanEndPoint(body: request)
        try await networkService.request(endPoint)
    }

    func repayLoan(with request: RepayLoanRequest) async throws {
        let endPoint = RepayLoanEndPoint(body: request)
        try await networkService.request(endPoint)
    }
}
