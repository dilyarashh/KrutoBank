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

    @DIInject(\.oauthService, container: DI.container)
    private var oauthService: OAuthServiceProtocol

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
                print("gfhgfffds")
                try await oauthService.logout()
                state.isLogoutLoading = false
                delegate?.profileViewModelDidLogout(self)
            } catch {
                state.isLogoutLoading = false
                state.errorText = AppStrings.Common.error
            }
        }
    }
}
