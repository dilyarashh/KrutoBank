import SwiftUI

/// Standalone SwiftUI view that renders the global toast overlay.
/// Hosted as a transparent child view controller on top of TabBarController.
struct ToastOverlayView: View {
    @ObservedObject private var store = ToastStore.shared

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            if let message = store.current {
                ToastView(message: message)
                    .padding(.horizontal, 16)
                    .padding(.top, 56) // below status bar
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture { store.dismiss() }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.current)
    }
}
