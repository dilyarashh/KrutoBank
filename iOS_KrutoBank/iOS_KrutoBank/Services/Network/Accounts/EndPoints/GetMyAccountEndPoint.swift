import Foundation

struct GetMyAccountEndPoint: EndPoint {
    private let accountId: String

    init(accountId: String) {
        self.accountId = accountId
    }

    var baseURL: URL { APIConstants.accountsServiceBaseURL }
    var path: String { APIConstants.Accounts.myAccount(accountId: accountId) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
