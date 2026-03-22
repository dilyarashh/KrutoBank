import Foundation

struct UpdateHiddenAccountsEndPoint: EndPoint {
    private let body: [String]

    init(hiddenAccountIds: [String]) {
        self.body = hiddenAccountIds
    }

    var baseURL: URL { APIConstants.appSettingsServiceBaseURL }
    var path: String { APIConstants.AppSettings.hiddenAccounts }
    var method: HTTPMethod { .patch }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
