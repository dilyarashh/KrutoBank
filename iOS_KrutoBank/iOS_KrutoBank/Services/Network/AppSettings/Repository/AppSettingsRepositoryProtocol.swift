protocol AppSettingsRepositoryProtocol {
    func getSettings() async throws -> AppSettingsResponse
    func saveSettings(_ settings: AppSettingsResponse) async throws
}
