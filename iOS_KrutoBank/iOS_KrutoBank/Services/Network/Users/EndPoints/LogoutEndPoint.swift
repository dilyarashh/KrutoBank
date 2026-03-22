import Foundation

struct LogoutEndPoint: EndPoint {
    var baseURL: URL { APIConstants.usersServiceBaseURL }
    var path: String { OAuthConstants.logout }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
