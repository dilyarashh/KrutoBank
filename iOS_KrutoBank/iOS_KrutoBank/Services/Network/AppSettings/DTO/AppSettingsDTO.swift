import Foundation

// MARK: - DTOs

struct AppSettingsResponse: Codable {
    let theme: String           // "light" | "dark"
    let hiddenAccountIds: [String]
}

struct UpdateThemeRequest: Encodable {
    let theme: String
}

struct UpdateHiddenAccountsRequest: Encodable {
    let hiddenAccountIds: [String]
}
