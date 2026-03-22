import UIKit
import AuthenticationServices

protocol AuthCoordinatorDelegate: AnyObject {
    func authCoordinatorDidAuth(_ coordinator: AuthCoordinator)
}

class AuthCoordinator: NSObject, Coordinator {
    // MARK: - Properties

    weak var delegate: AuthCoordinatorDelegate?

    var childCoordinators: [Coordinator] = []
    var onDidFinish: (() -> Void)?

    let navigationController: NavigationController

    @DIInject(\.oauthService, container: DI.container)
    private var oauthService: OAuthServiceProtocol

    @DIInject(\.tokenStorage, container: DI.container)
    private var tokenStorage: TokenStorageProtocol

    required init(
        navigationController: NavigationController
    ) {
        self.navigationController = navigationController
    }

    // MARK: - Navigation

    func start(animated: Bool) {
        let viewModel = OAuthLoginViewModel()
        viewModel.delegate = self
        let viewController = OAuthLoginView(viewModel: viewModel).hostingController
        navigationController.setViewControllers([viewController], animated: animated)
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension AuthCoordinator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        navigationController.view.window ?? ASPresentationAnchor()
    }
}

// MARK: - OAuthLoginViewModelDelegate
extension AuthCoordinator: OAuthLoginViewModelDelegate {
    func oauthLoginViewModelDidAuthenticate(_ viewModel: OAuthLoginViewModel) {
        delegate?.authCoordinatorDidAuth(self)
    }
}
