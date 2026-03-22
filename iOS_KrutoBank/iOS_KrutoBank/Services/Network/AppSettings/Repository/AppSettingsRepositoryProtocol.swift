import Foundation

protocol AppSettingsRepositoryProtocol {
    func getSettings() async throws -> AppSettings
    func updateTheme(theme: String) async throws -> AppSettings
    func updateHiddenAccounts(hiddenAccounts: [String]) async throws -> AppSettings
}
