import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var mainCoordinator: MainCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        mainCoordinator = createMainCoordinator(scene: scene)
        mainCoordinator?.start(animated: false)
    }

    private func createMainCoordinator(scene: UIWindowScene) -> MainCoordinator {
        let window = UIWindow(windowScene: scene)
        let navigationController = NavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window

        return MainCoordinator(navigationController: navigationController)
    }
}
