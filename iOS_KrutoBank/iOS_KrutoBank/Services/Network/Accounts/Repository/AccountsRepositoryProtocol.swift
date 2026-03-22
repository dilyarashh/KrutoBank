import Foundation

protocol AccountsRepositoryProtocol {
    func openAccount(data: OpenAccountRequest) async throws
    func closeAccount(with accountId: String) async throws
    func depositAccount(data: AccountBalanceRequest) async throws
    func withdrawFromAccount(data: AccountBalanceRequest) async throws
    func transferMoney(data: TransferRequest) async throws
    func getMyAccount(with accountId: String) async throws -> AccountResponse
    func getMyAccounts() async throws -> [UserAccountResponse]
    func getMyOperations(with accountId: String) async throws -> [AccountOperationResponse]
}
