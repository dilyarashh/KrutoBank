import Foundation

struct RegisterEndPoint: EndPoint {
    private let body: AuthRegisterRequest

    init(body: AuthRegisterRequest) {
        self.body = body
    }

    var baseURL: URL { APIConstants.authServiceBaseURL }
    var path: String { OAuthConstants.register }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .none }
}
