import Foundation
import AuthenticationServices

final class OAuthService: OAuthServiceProtocol {

    private var authSession: ASWebAuthenticationSession?

    private var tokenEndpoint: URL {
        APIConstants.authServiceBaseURL.appendingPathComponent(OAuthConstants.token)
    }

    func startAuthFlow(from anchor: ASPresentationAnchor) async throws -> OAuthTokenResponse {
        let codeVerifier  = PKCEHelper.generateCodeVerifier()
        let codeChallenge = PKCEHelper.codeChallenge(from: codeVerifier)
        let state         = UUID().uuidString

        let authURL = OAuthConstants.authorizeURL(codeChallenge: codeChallenge, state: state)
        let contextProvider = PresentationContextProvider(anchor: anchor)

        let callbackURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: OAuthConstants.callbackScheme
            ) { url, error in
                if let error = error {
                    let code = (error as NSError).code
                    if code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: OAuthError.userCancelled)
                    } else {
                        continuation.resume(throwing: OAuthError.authSessionFailed(error))
                    }
                    return
                }
                guard let url = url else {
                    continuation.resume(throwing: OAuthError.missingCallbackURL)
                    return
                }
                continuation.resume(returning: url)
            }
            session.presentationContextProvider = contextProvider
            session.prefersEphemeralWebBrowserSession = false
            self.authSession = session
            session.start()
        }

        let code = try extractCode(from: callbackURL, expectedState: state)
        return try await exchangeCode(code, codeVerifier: codeVerifier)
    }

    func refreshAccessToken(refreshToken: String) async throws -> OAuthTokenResponse {
        var request = URLRequest(url: tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = OAuthConstants.refreshBody(refreshToken: refreshToken).urlEncoded
        return try await performTokenRequest(request)
    }
}

private extension OAuthService {
    func extractCode(from url: URL, expectedState: String) throws -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw OAuthError.invalidCallbackURL
        }
        let items = components.queryItems ?? []
        if let error = items.first(where: { $0.name == "error" })?.value {
            throw OAuthError.serverError(error)
        }
        guard let code = items.first(where: { $0.name == "code" })?.value else {
            throw OAuthError.missingAuthCode
        }
        return code
    }

    func exchangeCode(_ code: String, codeVerifier: String) async throws -> OAuthTokenResponse {
        var request = URLRequest(url: tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = OAuthConstants.tokenBody(code: code, codeVerifier: codeVerifier).urlEncoded
        return try await performTokenRequest(request)
    }

    func performTokenRequest(_ request: URLRequest) async throws -> OAuthTokenResponse {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw OAuthError.tokenExchangeFailed
        }
        return try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
    }
}

private extension Dictionary where Key == String, Value == String {
    var urlEncoded: Data? {
        map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
    }
}
