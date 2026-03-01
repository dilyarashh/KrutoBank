import UIKit

extension UIApplication {
    var safeAreaInsets: UIEdgeInsets {
        let scene = connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets ?? .zero
    }
}
