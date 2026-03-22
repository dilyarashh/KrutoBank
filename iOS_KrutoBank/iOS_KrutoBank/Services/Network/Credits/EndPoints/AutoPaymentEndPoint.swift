import Foundation

struct AutoPaymentEndPoint: EndPoint {
    private let body: AutoPaymentRequest

    init(body: AutoPaymentRequest) {
        self.body = body
    }

    var baseURL: URL { APIConstants.creditsServiceBaseURL }
    var path: String { APIConstants.Credits.autoPayment }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
