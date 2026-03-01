import SwiftUI

enum AppStrings {
    enum Login {
        static let title = "login.title"
        static let button = "login.button"
        static let loginPhoneNumberPlaceholder = "login.phoneNumber.placeholder"
        static let loginPasswordPlaceholder = "login.password.placeholder"
        static let phoneNumberError = "login.phone.error"
        static let passwordError = "login.password.error"
        static let loginError = "login.error"
        static let sessionExpired = "login.sessionExpired"
    }

    enum Tabs {
        static let accounts = "tabs.accounts"
        static let credits = "tabs.credits"
        static let profile = "tabs.profile"
    }

    enum Profile {
        static let fullName = "profile.fullName"
        static let phone = "profile.phone"
        static let email = "profile.email"
        static let role = "profile.role"
        static let blocked = "profile.blocked"
        static let noData = "profile.noData"
        static let logout = "profile.logout"
        static let roleClient = "role.client"
        static let roleEmployee = "role.employee"
    }

    enum Accounts {
        static let openAccount = "accounts.open"
        static let closeAccount = "accounts.close"
    }

    enum Credits {
        static let take = "credits.take"
        static let repay = "credits.repay"
    }

    enum Common {
        static let cancel = "common.cancel"
        static let ok = "common.ok"
        static let error = "common.error"
    }

    enum Errors {
        static let networkUnavailable = "error.networkUnavailable"
        static let timeout = "error.timeout"
        static let serverUnavailable = "error.serverUnavailable"
        static let parsingFailed = "error.parsingFailed"
        static let unknown = "error.unknown"
    }
}

extension String {
    var localization: LocalizedStringKey {
        LocalizedStringKey(self)
    }
}
