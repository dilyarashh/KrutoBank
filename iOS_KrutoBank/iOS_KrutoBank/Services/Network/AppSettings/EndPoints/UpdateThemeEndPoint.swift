import Foundation

struct UpdateThemeEndPoint: EndPoint {
    private let body: String

    init(theme: String) {
        self.body = theme
    }

    var baseURL: URL { APIConstants.appSettingsServiceBaseURL }
    var path: String { APIConstants.AppSettings.theme }
    var method: HTTPMethod { .patch }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
