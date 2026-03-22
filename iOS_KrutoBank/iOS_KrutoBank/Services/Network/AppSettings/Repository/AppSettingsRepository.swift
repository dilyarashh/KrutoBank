import Foundation

// MARK: - Protocol
protocol AppSettingsRepositoryProtocol {
    func getSettings() async throws -> AppSettingsResponse
    func saveSettings(_ settings: AppSettingsResponse) async throws
}

// MARK: - Repository
final class AppSettingsRepository: AppSettingsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getSettings() async throws -> AppSettingsResponse {
        try await networkService.requestDecodable(GetAppSettingsEndPoint(), as: AppSettingsResponse.self)
    }

    func saveSettings(_ settings: AppSettingsResponse) async throws {
        try await networkService.request(UpdateAppSettingsEndPoint(body: settings))
    }
}
