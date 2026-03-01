import Foundation

struct GetTariffs: EndPoint {
    var baseURL: URL { APIConstants.creditsServiceBaseURL }
    var path: String { APIConstants.Credits.tariffs }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
