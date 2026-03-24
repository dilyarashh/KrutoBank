import Foundation

struct SetInitialPasswordEndPoint: EndPoint {
    private let body: SetInitialPasswordRequest

    init(body: SetInitialPasswordRequest) {
        self.body = body
    }

    var baseURL: URL { APIConstants.authServiceBaseURL }
    var path: String { OAuthConstants.setInitialPassword }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .none }
}
