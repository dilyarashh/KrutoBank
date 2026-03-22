import Foundation

final class AccountsRepository: AccountsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func openAccount(data: OpenAccountRequest) async throws {
        let endPoint = OpenAccountEndPoint(body: data)
        try await networkService.request(endPoint)
    }

    func closeAccount(with accountId: String) async throws {
        let endPoint = CloseAccountEndPoint(accountId: accountId)
        try await networkService.request(endPoint)
    }

    func depositAccount(data: AccountBalanceRequest) async throws {
        let endPoint = DepositAccountEndPoint(body: data)
        try await networkService.request(endPoint)
    }

    func withdrawFromAccount(data: AccountBalanceRequest) async throws {
        let endPoint = WithdrawFromAccountEndPoint(body: data)
        try await networkService.request(endPoint)
    }

    func transferMoney(data: TransferRequest) async throws {
        let endPoint = TransferEndPoint(body: data)
        try await networkService.request(endPoint)
    }

    func getMyAccounts() async throws -> [UserAccountResponse] {
        let endPoint = GetMyAccountsEndPoint()
        return try await networkService.requestDecodable(endPoint, as: [UserAccountResponse].self)
    }

    func getMyAccount(with accountId: String) async throws -> AccountResponse {
        let endPoint = GetMyAccountEndPoint(accountId: accountId)
        return try await networkService.requestDecodable(endPoint, as: AccountResponse.self)
    }

    func getMyOperations(with accountId: String) async throws -> [AccountOperationResponse] {
        let endPoint = GetMyOperationsEndPoint(accountId: accountId)
        return try await networkService.requestDecodable(endPoint, as: [AccountOperationResponse].self)
    }
}
