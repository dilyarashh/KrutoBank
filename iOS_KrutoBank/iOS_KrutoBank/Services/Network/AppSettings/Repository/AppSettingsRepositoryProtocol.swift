protocol AppSettingsRepositoryProtocol {
    func getSettings() async throws -> AppSettingsResponse
    func updateTheme(theme: String) async throws -> AppSettingsResponse
    func updateHiddenAccounts(hiddenAccounts: [String]) async throws -> AppSettingsResponse
}
