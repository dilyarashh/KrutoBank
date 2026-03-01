import Foundation

struct OpenAccountEndPoint: EndPoint {
    private let body: OpenAccountRequest

    init(
        body: OpenAccountRequest
    ) {
        self.body = body
    }

    var baseURL: URL { APIConstants.accountsServiceBaseURL }
    var path: String { APIConstants.Accounts.open }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
