import Foundation

final class AccountsRepository: AccountsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func openAccount(with name: String) async throws {
        let dto = OpenAccountRequest(name: name)
        let endPoint = OpenAccountEndPoint(body: dto)
        return try await networkService.request(endPoint)
    }

    func closeAccount(with accountId: String) async throws {
        let endPoint = CloseAccountEndPoint(accountId: accountId)
        try await networkService.request(endPoint)
    }

    func depositAccount(with accountId: String, amount: Double) async throws {
        let dto = AccountBalanceRequest(accountId: accountId, amount: amount)
        let endPoint = DepositAccountEndPoint(body: dto)
        try await networkService.request(endPoint)
    }

    func withdrawFromAccount(with accountId: String, amount: Double) async throws {
        let dto = AccountBalanceRequest(accountId: accountId, amount: amount)
        let endPoint = WithdrawFromAccountEndPoint(body: dto)
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
