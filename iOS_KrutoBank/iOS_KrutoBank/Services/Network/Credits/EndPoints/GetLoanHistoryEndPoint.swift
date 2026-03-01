import Foundation

struct GetLoanHistoryEndPoint: EndPoint {
    private let userId: String
    private let loanId: String

    init(
        userId: String,
        loanId: String
    ) {
        self.userId = userId
        self.loanId = loanId
    }

    var baseURL: URL { APIConstants.creditsServiceBaseURL }
    var path: String { APIConstants.Credits.loanOperations(userId: userId, loanId: loanId) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
