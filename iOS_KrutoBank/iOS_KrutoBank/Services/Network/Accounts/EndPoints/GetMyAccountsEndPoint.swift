import Foundation

struct GetMyAccountsEndPoint: EndPoint {
    var baseURL: URL { APIConstants.accountsServiceBaseURL }
    var path: String { APIConstants.Accounts.myAccounts }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
