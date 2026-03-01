import Foundation

struct GetMyInfoEndPoint: EndPoint {
    var baseURL: URL { APIConstants.usersServiceBaseURL }
    var path: String { APIConstants.Users.myself }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
