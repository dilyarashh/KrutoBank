import SwiftUI
import AuthenticationServices

/// SSO login screen. The app does NOT handle login/password itself.
/// It opens the authorization server's login page via ASWebAuthenticationSession.
struct OAuthLoginView: View {
    @ObservedObject var viewModel: OAuthLoginViewModel

    var body: some View {
        ZStack {
            Color.AppColor.backgroundMain.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Logo / Brand
                VStack(spacing: 12) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.AppColor.primaryPink)

                    Text("KrutoBank")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.AppColor.primaryDark)

                    Text("Войдите через единый аккаунт")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Error block
                if let error = viewModel.state.errorMessage {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.AppColor.textError)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // SSO Login button
                signInButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }
        }
        // Provide ASPresentationAnchor via environment
        .background(WindowAccessor { window in
            // stored for access in button
            _ = window
        })
    }

    private var signInButton: some View {
        CommonButton(
            title: "Войти через SSO",
            style: .primary,
            isLoading: viewModel.state.isLoading,
            disabled: viewModel.state.isLoading
        ) {
            guard let window = UIApplication.shared
                .connectedScenes
                .flatMap({ ($0 as? UIWindowScene)?.windows ?? [] })
                .first(where: { $0.isKeyWindow }) else { return }
            viewModel.loginWithSSO(anchor: window)
        }
    }
}

// MARK: - WindowAccessor helper
private struct WindowAccessor: UIViewRepresentable {
    var callback: (UIWindow?) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
