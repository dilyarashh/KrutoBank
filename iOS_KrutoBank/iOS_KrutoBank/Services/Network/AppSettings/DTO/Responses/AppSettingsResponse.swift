import Foundation

// MARK: - DTO

struct AppSettingsResponse: Decodable, Sendable {
    let theme: String
    let hiddenAccountIds: [String]
}

// MARK: - Mapper

extension AppSettingsResponse {
    func toDomain() -> AppSettings {
        AppSettings(
            theme: AppTheme(rawValue: theme) ?? .light,
            hiddenAccountIds: hiddenAccountIds
        )
    }
}
