import AuthenticationServices

protocol OAuthServiceProtocol {
    func startAuthFlow(from anchor: ASPresentationAnchor) async throws -> OAuthTokenResponse
    func refreshAccessToken(refreshToken: String) async throws -> OAuthTokenResponse
    func register(_ request: AuthRegisterRequest) async throws
    func setInitialPassword(_ request: SetInitialPasswordRequest) async throws
    func changePassword(_ request: ChangePasswordRequest) async throws
    func logout() async throws
}
