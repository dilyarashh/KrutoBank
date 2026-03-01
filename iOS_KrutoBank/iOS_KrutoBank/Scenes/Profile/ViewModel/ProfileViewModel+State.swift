import SwiftUI

extension ProfileViewModel {
    struct State {
        var user: UserResponse? = nil
        var errorText: String? = nil
        var isLoading: Bool = false
        var isLogoutLoading: Bool = false
    }
}
