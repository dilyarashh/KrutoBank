import UIKit

enum Constants {
    static var tabBarHeight: CGFloat {
        let safeAreaInset = UIApplication.shared.safeAreaInsets.bottom
        let tabBarHeight: CGFloat = 42
        let topInset: CGFloat = 7
        let bottomInset: CGFloat = safeAreaInset > 0 ? 0 : 6
        return tabBarHeight + topInset + bottomInset
    }

    static var statusBarHeight: CGFloat {
        UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?
            .windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
}
