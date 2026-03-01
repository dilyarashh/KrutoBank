import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func authCoordinatorDidAuth(_ coordinator: AuthCoordinator)
}

class AuthCoordinator: Coordinator {
    // MARK: - Properties

    weak var delegate: AuthCoordinatorDelegate?

    var childCoordinators: [Coordinator] = []
    var onDidFinish: (() -> Void)?

    let navigationController: NavigationController

    required init(
        navigationController: NavigationController
    ) {
        self.navigationController = navigationController
    }

    // MARK: - Navigation

    func start(animated: Bool) {
        let viewModel = AuthViewModel()
        viewModel.delegate = self

        let viewController = AuthView(viewModel: viewModel).hostingController

        navigationController.setViewControllers([viewController], animated: animated)
    }
}

extension AuthCoordinator: AuthViewModelDelegate {
    func authViewModelDidLoginSuccessfully(_ viewModel: AuthViewModel) {
        delegate?.authCoordinatorDidAuth(self)
    }
}
