import Foundation

struct DepositAccountEndPoint: EndPoint {
    private let body: AccountBalanceRequest

    init(
        body: AccountBalanceRequest
    ) {
        self.body = body
    }

    var baseURL: URL { APIConstants.accountsServiceBaseURL }
    var path: String { APIConstants.Accounts.deposit }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
