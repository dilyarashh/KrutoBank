struct AppSettings {
    let theme: AppTheme
    let hiddenAccountIds: [String]

    func isHidden(accountId: String) -> Bool {
        hiddenAccountIds.contains(accountId)
    }
}
