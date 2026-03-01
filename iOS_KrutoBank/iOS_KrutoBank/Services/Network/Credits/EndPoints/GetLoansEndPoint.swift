import Foundation

struct GetLoansEndPoint: EndPoint {
    private let userId: String

    init(
        userId: String
    ) {
        self.userId = userId
    }

    var baseURL: URL { APIConstants.creditsServiceBaseURL }
    var path: String { APIConstants.Credits.userLoans(userId: userId) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
