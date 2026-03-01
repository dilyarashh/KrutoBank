import Foundation

struct TakeLoanEndPoint: EndPoint {
    private let body: TakeLoanRequest

    init(
        body: TakeLoanRequest
    ) {
        self.body = body
    }

    var baseURL: URL { APIConstants.creditsServiceBaseURL }
    var path: String { APIConstants.Credits.takeLoan }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
