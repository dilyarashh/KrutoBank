import Foundation

struct RepayLoanEndPoint: EndPoint {
    private let body: RepayLoanRequest

    init(
        body: RepayLoanRequest
    ) {
        self.body = body
    }

    var baseURL: URL { APIConstants.creditsServiceBaseURL }
    var path: String { APIConstants.Credits.repayLoan }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
