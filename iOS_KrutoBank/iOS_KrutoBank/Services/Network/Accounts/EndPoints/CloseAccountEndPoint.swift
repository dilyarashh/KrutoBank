import Foundation

struct CloseAccountEndPoint: EndPoint {
    private let accountId: String

    init(
        accountId: String
    ) {
        self.accountId = accountId
    }

    var baseURL: URL { APIConstants.accountsServiceBaseURL }
    var path: String { APIConstants.Accounts.close }
    var method: HTTPMethod { .patch }
    var task: HTTPTask {
        .requestUrlParameters(["id": accountId])
    }
    var authorization: AuthorizationRequirement { .accessToken }
}
