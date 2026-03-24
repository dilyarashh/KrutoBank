import Foundation

final class AppSettingsRepository: AppSettingsRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getSettings() async throws -> AppSettings {
        let response = try await networkService.requestDecodable(GetAppSettingsEndPoint(), as: AppSettingsResponse.self)
        return response.toDomain()
    }

    func updateTheme(theme: String) async throws -> AppSettings {
        try await networkService.request(
            UpdateThemeEndPoint(theme: theme)
        )

        return try await getSettings()
    }

    func updateHiddenAccounts(hiddenAccounts: [String]) async throws -> AppSettings {
        try await networkService.request(
            UpdateHiddenAccountsEndPoint(hiddenAccountIds: hiddenAccounts)
        )

        return try await getSettings()
    }
}
