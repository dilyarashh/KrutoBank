import Foundation

struct TokenEndPoint: EndPoint {
    private let parameters: [String: String]

    init(body: [String: String]) {
        self.parameters = body
    }

    var baseURL: URL { APIConstants.authServiceBaseURL }
    var path: String { OAuthConstants.token }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestFormUrlEncoded(parameters) }
    var authorization: AuthorizationRequirement { .none }
}
