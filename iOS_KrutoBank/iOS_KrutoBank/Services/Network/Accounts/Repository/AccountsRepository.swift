import Foundation

final class AccountsRepository: AccountsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func openAccount(data: OpenAccountRequest) async throws {
        try await networkService.request(OpenAccountEndPoint(body: data))
    }

    func closeAccount(with accountId: String) async throws {
        try await networkService.request(CloseAccountEndPoint(accountId: accountId))
    }

    func depositAccount(data: AccountBalanceRequest) async throws {
        try await networkService.request(DepositAccountEndPoint(body: data))
    }

    func withdrawFromAccount(data: AccountBalanceRequest) async throws {
        try await networkService.request(WithdrawFromAccountEndPoint(body: data))
    }

    func transferMoney(data: TransferRequest) async throws {
        try await networkService.request(TransferEndPoint(body: data))
    }

    func getMyAccounts() async throws -> [UserAccount] {
        let response = try await networkService.requestDecodable(GetMyAccountsEndPoint(), as: [UserAccountResponse].self)
        return response.map { $0.toDomain() }
    }

    func getMyAccount(with accountId: String) async throws -> Account {
        let response = try await networkService.requestDecodable(GetMyAccountEndPoint(accountId: accountId), as: AccountResponse.self)
        return response.toDomain()
    }

    func getMyOperations(with accountId: String) async throws -> [AccountOperation] {
        let response = try await networkService.requestDecodable(GetMyOperationsEndPoint(accountId: accountId), as: [AccountOperationResponse].self)
        return response.map { $0.toDomain() }
    }
}
