import Foundation

struct GetOverduePaymentsEndPoint: EndPoint {
    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    var baseURL: URL { APIConstants.creditsServiceBaseURL }
    var path: String { APIConstants.Credits.overduePayments(userId: userId) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
