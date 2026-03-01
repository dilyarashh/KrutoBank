import UIKit

final class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onDidFinish: (() -> Void)?

    let navigationController: NavigationController

    @DIInject(\.tokenStorage, container: DI.container)
    private var tokenStorage: TokenStorageProtocol

    init(navigationController: NavigationController) {
        self.navigationController = navigationController

        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handleLogoutNotification),
                    name: .userDidLogout,
                    object: nil
                )
    }

    @objc private func handleLogoutNotification() {
          DispatchQueue.main.async {
              self.resetCoordinators()
          }
      }

    func start(animated: Bool) {
        if tokenStorage.accessToken == nil {
            showAuth(animated: animated)
        } else {
            showMain(animated: animated)
        }
    }

    func showAuth(animated: Bool) {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.delegate = self
        authCoordinator.onDidFinish = { [weak self, weak authCoordinator] in
            guard let coordinator = authCoordinator else { return }
            self?.removeChildCoordinator(coordinator)
        }
        addChildCoordinator(authCoordinator)
        authCoordinator.start(animated: animated)
    }

    private func showMain(animated: Bool) {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        tabBarCoordinator.onDidFinish = { [weak self, weak tabBarCoordinator] in
            guard let coordinator = tabBarCoordinator else { return }
            self?.removeChildCoordinator(coordinator)
            self?.showAuth(animated: true)
        }
        addChildCoordinator(tabBarCoordinator)
        tabBarCoordinator.start(animated: animated)
    }

    private func resetCoordinators() {
        navigationController.dismiss(animated: false, completion: nil)
        navigationController.setViewControllers([], animated: false)
        navigationController.removeAllPopObservers()
        childCoordinators.removeAll()
        if let window = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?.windows
            .first(where: { $0.isKeyWindow }) {
            changeRootViewController(of: window, to: navigationController)
        }
        start(animated: false)
    }

    private func changeRootViewController(of window: UIWindow,
                                          to viewController: UIViewController,
                                          animationDuration: TimeInterval = 0.5) {
        let animations = {
            UIView.performWithoutAnimation {
                window.rootViewController = self.navigationController
            }
        }
        UIView.transition(with: window, duration: animationDuration, options: .transitionFlipFromLeft,
                          animations: animations, completion: nil)
    }

    private func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    private func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}

// MARK: - AuthCoordinatorDelegate
extension MainCoordinator: AuthCoordinatorDelegate {
    func authCoordinatorDidAuth(_ coordinator: AuthCoordinator) {
        resetCoordinators()
    }
}
