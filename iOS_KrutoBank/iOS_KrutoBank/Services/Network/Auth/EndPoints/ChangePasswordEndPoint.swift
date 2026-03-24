import Foundation

struct ChangePasswordEndPoint: EndPoint {
    private let body: ChangePasswordRequest

    init(body: ChangePasswordRequest) {
        self.body = body
    }

    var baseURL: URL { APIConstants.authServiceBaseURL }
    var path: String { OAuthConstants.changePassword }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .accessToken }
}
