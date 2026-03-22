import Foundation

protocol AccountsRepositoryProtocol {
    func openAccount(with name: String, currency: String) async throws
    func closeAccount(with accountId: String) async throws
    func depositAccount(with accountId: String, amount: Double) async throws
    func withdrawFromAccount(with accountId: String, amount: Double) async throws
    func transferMoney(from fromId: String, to toId: String, amount: Double, currency: String) async throws
    func getMyAccount(with accountId: String) async throws -> AccountResponse
    func getMyAccounts() async throws -> [UserAccountResponse]
    func getMyOperations(with accountId: String) async throws -> [AccountOperationResponse]
}
