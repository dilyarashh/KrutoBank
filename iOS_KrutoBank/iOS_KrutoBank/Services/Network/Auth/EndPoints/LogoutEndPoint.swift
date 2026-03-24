import Foundation

struct LogoutEndPoint: EndPoint {
    private let returnUrl: String

    init(returnUrl: String = OAuthConstants.redirectURI) {
        self.returnUrl = returnUrl
    }

    var baseURL: URL { APIConstants.authServiceBaseURL }
    var path: String { OAuthConstants.accountLogout }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .requestMultipart(["returnUrl": returnUrl]) }
    var authorization: AuthorizationRequirement { .accessToken }
}
