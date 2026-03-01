import UIKit

class AccountsCoordinator: Coordinator {
    // MARK: - Properties

    var childCoordinators: [Coordinator] = []
    var onDidFinish: (() -> Void)?

    let navigationController: NavigationController

    required init(navigationController: NavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Navigation

    func start(animated: Bool) {
        let viewModel = AccountsViewModel()
        let viewController = AccountsView(viewModel: viewModel).hostingController
        navigationController.pushViewController(viewController, animated: animated)
    }
}
