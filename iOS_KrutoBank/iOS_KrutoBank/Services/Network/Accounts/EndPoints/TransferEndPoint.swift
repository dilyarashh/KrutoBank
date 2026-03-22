import Foundation

struct TransferEndPoint: EndPoint {
    private let body: TransferRequest

    init(body: TransferRequest) {
        self.body = body
    }

    var baseURL: URL { APIConstants.accountsServiceBaseURL }
    var path: String { APIConstants.Accounts.transfer }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
