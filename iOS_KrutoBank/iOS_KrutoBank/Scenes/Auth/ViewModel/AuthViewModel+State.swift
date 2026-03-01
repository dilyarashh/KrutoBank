import SwiftUI

extension AuthViewModel {
    struct State {
        var phone: String = ""
        var password: String = ""
        var errorText: String? = nil
        var isLoading: Bool = false
    }
}
