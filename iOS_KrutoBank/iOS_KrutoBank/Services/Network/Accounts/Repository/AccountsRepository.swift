import Foundation

final class AccountsRepository: AccountsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    nonisolated init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    nonisolated func openAccount(data: OpenAccountRequest) async throws {
        try await networkService.request(OpenAccountEndPoint(body: data))
    }

    nonisolated func closeAccount(with accountId: String) async throws {
        try await networkService.request(CloseAccountEndPoint(accountId: accountId))
    }

    nonisolated func depositAccount(data: AccountBalanceRequest) async throws {
        try await networkService.request(DepositAccountEndPoint(body: data))
    }

    nonisolated func withdrawFromAccount(data: AccountBalanceRequest) async throws {
        try await networkService.request(WithdrawFromAccountEndPoint(body: data))
    }

    nonisolated func transferMoney(data: TransferRequest) async throws {
        try await networkService.request(TransferEndPoint(body: data))
    }

    nonisolated func getMyAccounts() async throws -> [UserAccount] {
        let response = try await networkService.requestDecodable(GetMyAccountsEndPoint(), as: [UserAccountResponse].self)
        return response.map { $0.toDomain() }
    }

    nonisolated func getMyAccount(with accountId: String) async throws -> Account {
        let response = try await networkService.requestDecodable(GetMyAccountEndPoint(accountId: accountId), as: AccountResponse.self)
        return response.toDomain()
    }

    nonisolated func getMyOperations(with accountId: String) async throws -> [AccountOperation] {
        let response = try await networkService.requestDecodable(GetMyOperationsEndPoint(accountId: accountId), as: [AccountOperationResponse].self)
        return response.map { $0.toDomain() }
    }
}
