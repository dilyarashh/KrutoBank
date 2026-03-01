import SwiftUI

enum TabBarItem: Int, CaseIterable {
    case accounts, credits, profile

    var title: LocalizedStringKey {
        switch self {
        case .accounts:
            return AppStrings.Tabs.accounts.localization
        case .credits:
            return AppStrings.Tabs.credits.localization
        case .profile:
            return AppStrings.Tabs.profile.localization
        }
    }

    var icon: Image {
        switch self {
        case .accounts:
            return Image(systemName: "creditcard")
        case .credits:
            return Image(systemName: "banknote")
        case .profile:
            return Image(systemName: "person.circle")
        }
    }
}
