import SwiftUI

extension View {
    var hostingController: UIHostingController<Self> {
        let viewController = UIHostingController(rootView: self)
        viewController.view.backgroundColor = UIColor(named: "BackgroundMain") ?? .systemBackground
        return viewController
    }
}
