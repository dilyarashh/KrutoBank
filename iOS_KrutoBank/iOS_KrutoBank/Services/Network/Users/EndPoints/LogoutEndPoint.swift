import Foundation

struct LogoutEndPoint: EndPoint {
    var baseURL: URL { APIConstants.usersServiceBaseURL }
    var path: String { APIConstants.Users.logout }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
