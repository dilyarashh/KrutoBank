import UIKit

class CreditsCoordinator: Coordinator {
    // MARK: - Properties
    
    var childCoordinators: [Coordinator] = []
    var onDidFinish: (() -> Void)?
    
    let navigationController: NavigationController
    
    required init(navigationController: NavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Navigation
    
    func start(animated: Bool) {
        let viewModel = CreditsViewModel()
        let viewController = CreditsView(viewModel: viewModel).hostingController
        navigationController.pushViewController(viewController, animated: animated)
    }
}
