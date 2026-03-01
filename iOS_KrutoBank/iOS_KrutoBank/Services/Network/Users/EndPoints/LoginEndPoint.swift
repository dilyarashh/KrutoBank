import Foundation

struct LoginEndPoint: EndPoint {
    private let body: LoginRequest

    init(
        body: LoginRequest
    ) {
        self.body = body
    }

    var baseURL: URL { APIConstants.usersServiceBaseURL }
    var path: String { APIConstants.Users.login }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestBody(body) }
    var authorization: AuthorizationRequirement { .none }
}
