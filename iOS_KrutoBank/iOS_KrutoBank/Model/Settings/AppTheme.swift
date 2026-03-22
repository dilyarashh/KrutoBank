enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark  = "Dark"

    var displayName: String {
        switch self {
        case .light:
            return "Светлая"
        case .dark: 
            return "Тёмная"
        }
    }
}
