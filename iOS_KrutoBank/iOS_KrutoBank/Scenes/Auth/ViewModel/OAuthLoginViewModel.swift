import Foundation
import Combine
import AuthenticationServices

protocol OAuthLoginViewModelDelegate: AnyObject {
    func oauthLoginViewModelDidAuthenticate(_ viewModel: OAuthLoginViewModel)
}

@MainActor
final class OAuthLoginViewModel: ObservableObject {
    weak var delegate: OAuthLoginViewModelDelegate?

    @DIInject(\.oauthService, container: DI.container)
    private var oauthService: OAuthServiceProtocol

    private var tokenStorage: TokenStorageProtocol

    @Published var state = State()

    init() {
        self.tokenStorage = DI.container.tokenStorage
    }

    // Called from View, passing the window anchor for ASWebAuthenticationSession
    func loginWithSSO(anchor: ASPresentationAnchor) {
        guard !state.isLoading else { return }
        state.isLoading = true
        state.errorMessage = nil

        Task {
            do {
                let tokenResponse = try await oauthService.startAuthFlow(from: anchor)
                tokenStorage.accessToken = tokenResponse.accessToken
                tokenStorage.refreshToken = tokenResponse.refreshToken
                state.isLoading = false
                delegate?.oauthLoginViewModelDidAuthenticate(self)
            } catch OAuthError.userCancelled {
                state.isLoading = false
                // No error shown when user cancels
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
}

extension OAuthLoginViewModel {
    struct State {
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }
}
