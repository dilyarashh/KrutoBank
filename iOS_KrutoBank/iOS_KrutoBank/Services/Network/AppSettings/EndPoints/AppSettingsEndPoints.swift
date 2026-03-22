import Foundation

struct GetAppSettingsEndPoint: EndPoint {
    var baseURL: URL { APIConstants.appSettingsServiceBaseURL }
    var path: String { APIConstants.AppSettings.settings }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}

struct UpdateAppSettingsEndPoint: EndPoint {
    private let body: AppSettingsResponse

    init(body: AppSettingsResponse) {
        self.body = body
    }

    var baseURL: URL { APIConstants.appSettingsServiceBaseURL }
    var path: String { APIConstants.AppSettings.settings }
    var method: HTTPMethod { .put }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
