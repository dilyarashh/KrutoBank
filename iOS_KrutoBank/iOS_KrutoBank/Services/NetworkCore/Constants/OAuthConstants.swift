import Foundation

enum OAuthConstants {
    static let authorize = "/connect/authorize"
    static let token     = "/connect/token"
    static let logout    = "/connect/logout"
    static let register  = "/account/register"

    static let clientId       = "bank-client-web"
    static let redirectURI    = "http://localhost:3000/auth/callback"
    static let responseType   = "code"
    static let grantType      = "authorization_code"
    static let refreshGrant   = "refresh_token"
    static let scope          = "openid profile offline_access"
    static let callbackScheme = "krutobank"

    private static var baseURL: URL { APIConstants.authServiceBaseURL }

    static func authorizeURL(codeChallenge: String, state: String) -> URL {
        var c = URLComponents(url: baseURL.appendingPathComponent(authorize), resolvingAgainstBaseURL: false)!
        c.queryItems = [
            URLQueryItem(name: "client_id",             value: clientId),
            URLQueryItem(name: "redirect_uri",          value: redirectURI),
            URLQueryItem(name: "response_type",         value: responseType),
            URLQueryItem(name: "scope",                 value: scope),
            URLQueryItem(name: "code_challenge",        value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state",                 value: state),
        ]
        return c.url!
    }

    static func tokenBody(code: String, codeVerifier: String) -> [String: String] {
        ["grant_type":    grantType,
         "code":          code,
         "redirect_uri":  redirectURI,
         "client_id":     clientId,
         "code_verifier": codeVerifier]
    }

    static func refreshBody(refreshToken: String) -> [String: String] {
        ["grant_type":    refreshGrant,
         "refresh_token": refreshToken,
         "client_id":     clientId]
    }

    static func logoutURL(idTokenHint: String? = nil) -> URL {
        var c = URLComponents(url: baseURL.appendingPathComponent(logout), resolvingAgainstBaseURL: false)!
        var items: [URLQueryItem] = [
            URLQueryItem(name: "post_logout_redirect_uri", value: redirectURI),
            URLQueryItem(name: "client_id",                value: clientId),
        ]
        if let hint = idTokenHint {
            items.append(URLQueryItem(name: "id_token_hint", value: hint))
        }
        c.queryItems = items
        return c.url!
    }
}

