import Foundation

struct GetAppSettingsEndPoint: EndPoint {
    var baseURL: URL { APIConstants.appSettingsServiceBaseURL }
    var path: String { APIConstants.AppSettings.settings }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
