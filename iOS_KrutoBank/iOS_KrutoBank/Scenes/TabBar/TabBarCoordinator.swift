import UIKit

class TabBarCoordinator: Coordinator {
    // MARK: - Properties

    var childCoordinators: [Coordinator] = []
    var onDidFinish: (() -> Void)?

    let navigationController: NavigationController

    required init(navigationController: NavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Navigation

    func start(animated: Bool) {
        let accountsNavigationController = createAccountsNavigationController()
        let creditsNavigationController = createCreditsNavigationController()
        let profileNavigationController = createProfileNavigationController()

        let viewController = TabBarController(tabViewControllers: [
            accountsNavigationController,
            creditsNavigationController,
            profileNavigationController
        ])

        navigationController.setViewControllers([viewController], animated: animated)
    }

    // MARK: - Private methods

    private func createAccountsNavigationController() -> NavigationController {
        let navController = NavigationController()
        let coordinator = AccountsCoordinator(navigationController: navController)
        add(coordinator)
        coordinator.start(animated: false)
        return navController
    }

    private func createCreditsNavigationController() -> NavigationController {
        let navController = NavigationController()
        let coordinator = CreditsCoordinator(navigationController: navController)
        add(coordinator)
        coordinator.start(animated: false)
        return navController
    }

    private func createProfileNavigationController() -> NavigationController {
        let navController = NavigationController()
        let coordinator = ProfileCoordinator(navigationController: navController)
        coordinator.delegate = self
        add(coordinator)
        coordinator.start(animated: false)
        return navController
    }
}

extension TabBarCoordinator: ProfileCoordinatorDelegate {
    func profileCoordinatorDidLogout(_ coordinator: ProfileCoordinator) {
        remove(coordinator)
        onDidFinish?()
    }
}
