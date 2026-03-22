import Foundation

protocol CreditsRepositoryProtocol {
    func getTariffs() async throws -> [Tariff]
    func getLoans(with userId: String) async throws -> [Credit]
    func getLoanHistory(with userId: String, loanId: String) async throws -> [LoanOperation]
    func takeLoan(with request: TakeLoanRequest) async throws
    func repayLoan(with request: RepayLoanRequest) async throws
    func getCreditRating(userId: String) async throws -> CreditRating
}
