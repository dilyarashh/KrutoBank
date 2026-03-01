import Foundation

protocol CreditsRepositoryProtocol {
    func getTariffs() async throws -> [TariffResponse]
    func getLoans(with userId: String) async throws -> [CreditResponse]
    func getLoanHistory(with userId: String, loanId: String) async throws -> [LoanOperationResponse]
    func takeLoan(with request: TakeLoanRequest) async throws
    func repayLoan(with request: RepayLoanRequest) async throws
}
