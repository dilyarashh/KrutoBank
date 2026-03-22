import UIKit
import AuthenticationServices

protocol AuthCoordinatorDelegate: AnyObject {
    func authCoordinatorDidAuth(_ coordinator: AuthCoordinator)
}

final class AuthCoordinator: NSObject, Coordinator {

    // MARK: - Properties

    weak var delegate: AuthCoordinatorDelegate?

    var childCoordinators: [Coordinator] = []
    var onDidFinish: (() -> Void)?
    let navigationController: NavigationController

    // MARK: - Initialization

    required init(navigationController: NavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Navigation

    func start(animated: Bool) {
        let viewModel = OAuthLoginViewModel()
        viewModel.delegate = self
        let vc = OAuthLoginView(viewModel: viewModel).hostingController
        navigationController.setViewControllers([vc], animated: animated)
    }
}

// MARK: - OAuthLoginViewModelDelegate

extension AuthCoordinator: OAuthLoginViewModelDelegate {
    func oauthLoginViewModelDidAuthenticate(_ viewModel: OAuthLoginViewModel) {
        delegate?.authCoordinatorDidAuth(self)
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension AuthCoordinator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        navigationController.view.window ?? ASPresentationAnchor()
    }
}
