import Foundation
import AuthenticationServices

// MARK: - OAuth Configuration
struct OAuthConfig {
    let authorizationEndpoint: URL
    let tokenEndpoint: URL
    let clientId: String
    let redirectURI: String
    let scopes: [String]

    static let `default` = OAuthConfig(
        authorizationEndpoint: URL(string: "\(APIConstants.authServiceBaseURL)/connect/authorize")!,
        tokenEndpoint: URL(string: "\(APIConstants.authServiceBaseURL)/connect/token")!,
        clientId: "ios-client",
        redirectURI: "krutobank://auth/callback",
        scopes: ["openid", "profile", "offline_access", "accounts", "credits"]
    )
}

// MARK: - Token Exchange Response
struct OAuthTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

// MARK: - OAuthServiceProtocol
protocol OAuthServiceProtocol {
    func startAuthFlow(from anchor: ASPresentationAnchor) async throws -> OAuthTokenResponse
    func refreshAccessToken(refreshToken: String) async throws -> OAuthTokenResponse
}

// MARK: - PresentationContextProvider
private final class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    let anchor: ASPresentationAnchor
    init(anchor: ASPresentationAnchor) { self.anchor = anchor }
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor { anchor }
}

// MARK: - OAuthService
final class OAuthService: NSObject, OAuthServiceProtocol {
    private let config: OAuthConfig
    private var authSession: ASWebAuthenticationSession?

    init(config: OAuthConfig = .default) {
        self.config = config
    }

    func startAuthFlow(from anchor: ASPresentationAnchor) async throws -> OAuthTokenResponse {
        let codeVerifier = PKCEHelper.generateCodeVerifier()
        let codeChallenge = PKCEHelper.codeChallenge(from: codeVerifier)
        let state = UUID().uuidString

        let authURL = try buildAuthorizationURL(codeChallenge: codeChallenge, state: state)
        let contextProvider = PresentationContextProvider(anchor: anchor)

        let callbackURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "krutobank"
            ) { url, error in
                if let error = error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
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
        var request = URLRequest(url: config.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": config.clientId
        ]
        request.httpBody = body.urlEncoded

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw OAuthError.tokenExchangeFailed
        }
        return try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
    }
}

// MARK: - Private helpers
private extension OAuthService {
    func buildAuthorizationURL(codeChallenge: String, state: String) throws -> URL {
        guard var components = URLComponents(url: config.authorizationEndpoint, resolvingAgainstBaseURL: false) else {
            throw OAuthError.invalidConfiguration
        }
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "scope", value: config.scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        guard let url = components.url else { throw OAuthError.invalidConfiguration }
        return url
    }

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
        var request = URLRequest(url: config.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": config.redirectURI,
            "client_id": config.clientId,
            "code_verifier": codeVerifier
        ]
        request.httpBody = body.urlEncoded

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw OAuthError.tokenExchangeFailed
        }
        return try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
    }
}

// MARK: - OAuthError
enum OAuthError: LocalizedError {
    case userCancelled
    case authSessionFailed(Error)
    case missingCallbackURL
    case invalidCallbackURL
    case missingAuthCode
    case tokenExchangeFailed
    case invalidConfiguration
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .userCancelled: return "Вход отменён"
        case .authSessionFailed(let e): return "Ошибка аутентификации: \(e.localizedDescription)"
        case .missingCallbackURL: return "Не получен callback URL"
        case .invalidCallbackURL: return "Некорректный callback URL"
        case .missingAuthCode: return "Отсутствует код авторизации"
        case .tokenExchangeFailed: return "Не удалось обменять код на токены"
        case .invalidConfiguration: return "Некорректная конфигурация OAuth"
        case .serverError(let msg): return "Ошибка сервера: \(msg)"
        }
    }
}

// MARK: - Dictionary URL encoding helper
private extension Dictionary where Key == String, Value == String {
    var urlEncoded: Data? {
        map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
    }
}
