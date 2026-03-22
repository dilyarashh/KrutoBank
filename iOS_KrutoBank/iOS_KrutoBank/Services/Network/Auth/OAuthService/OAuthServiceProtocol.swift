import AuthenticationServices

protocol OAuthServiceProtocol {
    func startAuthFlow(from anchor: ASPresentationAnchor) async throws -> OAuthTokenResponse
    func refreshAccessToken(refreshToken: String) async throws -> OAuthTokenResponse
}
