import Foundation

final class AppSettingsRepository: AppSettingsRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getSettings() async throws -> AppSettingsResponse {
        try await networkService.requestDecodable(
            GetAppSettingsEndPoint(),
            as: AppSettingsResponse.self
        )
    }

    func updateTheme(theme: String) async throws -> AppSettingsResponse {
        try await networkService.requestDecodable(
            UpdateThemeEndPoint(theme: theme),
            as: AppSettingsResponse.self
        )
    }

    func updateHiddenAccounts(hiddenAccounts: [String]) async throws -> AppSettingsResponse {
        try await networkService.requestDecodable(
            UpdateHiddenAccountsEndPoint(hiddenAccountIds: hiddenAccounts),
            as: AppSettingsResponse.self
        )
    }
}
