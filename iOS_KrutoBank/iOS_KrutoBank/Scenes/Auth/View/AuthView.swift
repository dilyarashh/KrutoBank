import SwiftUI

struct AuthView: View {
    @ObservedObject private var viewModel: AuthViewModel

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            title
            form
            loginButton
            Spacer()
        }
        .background(background)
        .dismissKeyboardOnTap()
    }
}

private extension AuthView {
    var background: some View {
        Color.AppColor.backgroundMain.ignoresSafeArea()
    }

    var title: some View {
        Text(AppStrings.Login.title.localization)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(Color.AppColor.textPrimary)
    }

    var form: some View {
        VStack(spacing: 12) {
            phoneField
            passwordField
            errorBlock
        }
        .padding(.horizontal, 20)
    }

    var phoneField: some View {
        TextInput(
            text: $viewModel.state.phone,
            placeholder: AppStrings.Login.loginPhoneNumberPlaceholder,
            type: .text,
            validator: viewModel.phoneValidator,
            formatter: PhoneFormatter(),
            keyboardType: .phonePad,
            textContentType: .telephoneNumber
        )
    }

    var passwordField: some View {
        TextInput(
            text: $viewModel.state.password,
            placeholder: AppStrings.Login.loginPasswordPlaceholder,
            type: .password,
            validator: viewModel.passwordValidator,
            keyboardType: .asciiCapable,
            textContentType: .password
        )
    }

    @ViewBuilder
    var errorBlock: some View {
        if let errorText = viewModel.state.errorText {
            Text(errorText.localization)
                .font(.system(size: 13))
                .foregroundStyle(Color.AppColor.textError)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
    }

    var loginButton: some View {
        CommonButton(
            title: AppStrings.Login.button,
            style: .primary,
            isLoading: viewModel.state.isLoading,
            disabled: !viewModel.canLogin
        ) {
            viewModel.login()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}
