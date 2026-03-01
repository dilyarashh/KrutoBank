import Foundation
import Combine

protocol AuthViewModelDelegate: AnyObject {
    func authViewModelDidLoginSuccessfully(_ viewModel: AuthViewModel)
}

@MainActor
final class AuthViewModel: ObservableObject {
    weak var delegate: AuthViewModelDelegate?

    @DIInject(\.usersRepository, container: DI.container)
    private var usersRepository: UsersRepositoryProtocol

    let phoneValidator = PhoneValidator()
    let passwordValidator = PasswordValidator()

    @Published
    var state = State()

    // MARK: - Validation

    var canLogin: Bool {
        isValid()
    }

    func isValid() -> Bool {
        guard phoneValidator.validate(state.phone).isValid else { return false }
        guard passwordValidator.validate(state.password).isValid else { return false }

        return true
    }

    // MARK: - Actions

    func login() {
        guard canLogin else { return }

        state.isLoading = true

        let phone = state.phone
        let password = state.password

        Task {
            do {
                try await usersRepository.login(with: phone, password: password)
                state.isLoading = false
                delegate?.authViewModelDidLoginSuccessfully(self)
            } catch {
                state.isLoading = false
                state.errorText = AppStrings.Login.loginError
            }
        }
    }
}
