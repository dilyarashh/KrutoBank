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
        let response = try await networkService.requestDecodable(UpdateThemeEndPoint(theme: theme), as: AppSettingsResponse.self)
        return response.toDomain()
    }

    func updateHiddenAccounts(hiddenAccounts: [String]) async throws -> AppSettings {
        let response = try await networkService.requestDecodable(UpdateHiddenAccountsEndPoint(hiddenAccountIds: hiddenAccounts), as: AppSettingsResponse.self)
        return response.toDomain()
    }
}
