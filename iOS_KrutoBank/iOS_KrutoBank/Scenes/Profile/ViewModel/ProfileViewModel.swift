import Foundation
import Combine

protocol ProfileViewModelDelegate: AnyObject {
    func profileViewModelDidLogout(_ viewModel: ProfileViewModel)
}

@MainActor
final class ProfileViewModel: ObservableObject {
    weak var delegate: ProfileViewModelDelegate?

    @DIInject(\.usersRepository, container: DI.container)
    private var usersRepository: UsersRepositoryProtocol

    @Published
    var state = State()

    func load() {
        guard !state.isLoading else { return }

        state.isLoading = true
        state.errorText = nil

        Task {
            do {
                let user = try await usersRepository.getMyInfo()
                state.user = user
                state.isLoading = false
            } catch {
                state.isLoading = false
                state.user = nil
                state.errorText = AppStrings.Common.error
            }
        }
    }

    func logout() {
        guard !state.isLogoutLoading else { return }

        state.isLogoutLoading = true
        state.errorText = nil

        Task {
            do {
                try await usersRepository.logout()
                state.isLogoutLoading = false
                delegate?.profileViewModelDidLogout(self)
            } catch {
                state.isLogoutLoading = false
                state.errorText = AppStrings.Common.error
            }
        }
    }

    func fullName(from user: UserResponse) -> String {
        let parts = [user.lastName, user.firstName, user.middleName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? "—" : parts.joined(separator: " ")
    }
}
