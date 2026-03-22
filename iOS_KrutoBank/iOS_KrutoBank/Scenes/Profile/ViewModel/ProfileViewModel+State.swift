import SwiftUI

extension ProfileViewModel {
    struct State {
        var user: UserProfile? = nil
        var errorText: String? = nil
        var isLoading: Bool = false
        var isLogoutLoading: Bool = false
    }
}
