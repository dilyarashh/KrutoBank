import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var mainCoordinator: MainCoordinator?
    private var themeCancellable: AnyCancellable?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        mainCoordinator = createMainCoordinator(scene: scene)
        mainCoordinator?.start(animated: false)

        observeTheme()
    }

    private func createMainCoordinator(scene: UIWindowScene) -> MainCoordinator {
        let window = UIWindow(windowScene: scene)
        let navigationController = NavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window

        return MainCoordinator(navigationController: navigationController)
    }

    private func observeTheme() {
        themeCancellable = ThemeManager.shared.$theme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] theme in
                self?.window?.overrideUserInterfaceStyle = theme == .dark ? .dark : .light
            }
    }
}
