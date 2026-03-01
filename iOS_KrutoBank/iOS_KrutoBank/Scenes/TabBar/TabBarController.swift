import UIKit
import SnapKit
import SwiftUI
import Combine

class TabBarController: UITabBarController {
    // MARK: - Properties

    @Published
    private var selectedTabItem: TabBarItem = .accounts

    private let tabViewControllers: [UIViewController]

    // MARK: - Init

    init(tabViewControllers: [UIViewController]) {
        self.tabViewControllers = tabViewControllers
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        viewControllers = tabViewControllers
        selectedIndex = selectedTabItem.rawValue
        setupTabBar()
    }

    private func setupTabBar() {
        tabBar.isHidden = true

        let tabBarView = TabBar(
            selectedTabItem: selectedTabItem,
            selectedTabItemPublisher: $selectedTabItem.eraseToAnyPublisher()
        ) { [weak self] item in
            self?.selectTab(item)
        }.hostingController
        addChild(tabBarView)
        view.addSubview(tabBarView.view)
        tabBarView.didMove(toParent: self)

        tabBarView.safeAreaRegions.remove(.all)

        tabBarView.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: Constants.tabBarHeight, right: 0)
    }

    // MARK: - Private methods

    private func selectTab(_ item: TabBarItem) {
        let shouldPop = selectedTabItem == item

        selectedIndex = item.rawValue
        selectedTabItem = item

        if shouldPop {
            (selectedViewController as? UINavigationController)?.popToRootViewController(animated: true)
        }
    }
}
