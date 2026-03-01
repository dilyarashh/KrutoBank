import UIKit

protocol ProfileCoordinatorDelegate: AnyObject {
    func profileCoordinatorDidLogout(_ coordinator: ProfileCoordinator)
}

class ProfileCoordinator: Coordinator {
    // MARK: - Properties

    var childCoordinators: [Coordinator] = []
    var onDidFinish: (() -> Void)?

    let navigationController: NavigationController
    weak var delegate: ProfileCoordinatorDelegate?

    required init(navigationController: NavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Navigation

    func start(animated: Bool) {
        let viewModel = ProfileViewModel()
        viewModel.delegate = self
        let viewController = ProfileView(viewModel: viewModel).hostingController
        navigationController.pushViewController(viewController, animated: animated)
    }
}

extension ProfileCoordinator: ProfileViewModelDelegate {
    func profileViewModelDidLogout(_ viewModel: ProfileViewModel) {
        delegate?.profileCoordinatorDidLogout(self)
        onDidFinish?()
    }
}
