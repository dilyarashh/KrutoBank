import Foundation

final class AuthorizationProvider: AuthorizationProvidingProtocol {
    private let tokenStorage: TokenStorageProtocol
    private let oauthService: OAuthServiceProtocol

    init(
        tokenStorage: TokenStorageProtocol,
        oauthService: OAuthServiceProtocol
    ) {
        self.tokenStorage = tokenStorage
        self.oauthService = oauthService
    }

    func addAuthorization(
        to request: URLRequest,
        requirement: AuthorizationRequirement
    ) async -> URLRequest {
        switch requirement {
        case .none:
            return request

        case .accessToken:
            if let token = await validAccessToken(), !token.isEmpty {
                return requestAddingBearer(token, to: request)
            }
            return request
        }
    }

    // MARK: - Token refresh
    private func validAccessToken() async -> String? {
        if let token = tokenStorage.accessToken, !token.isEmpty {
            return token
        }
        return nil
    }
}

extension AuthorizationProvider {
    func requestAddingBearer(_ token: String, to request: URLRequest) -> URLRequest {
        var modified = request
        modified.setValue(
            "\(HTTPHeaderValue.bearerPrefix) \(token)",
            forHTTPHeaderField: HTTPHeader.authorization
        )
        return modified
    }
}
