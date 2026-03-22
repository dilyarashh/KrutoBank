import SwiftUI
import Combine

// MARK: - ThemeManager
@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var theme: AppTheme = .light {
        didSet { syncToServer() }
    }
    @Published var hiddenAccountIds: Set<String> = [] {
        didSet { syncToServer() }
    }

    @DIInject(\.appSettingsRepository, container: DI.container)
    private var repository: AppSettingsRepositoryProtocol

    private var syncTask: Task<Void, Never>?

    private init() {}

    // MARK: - Load from server
    func loadFromServer() {
        Task {
            do {
                let settings = try await repository.getSettings()
                theme = settings.theme
                hiddenAccountIds = Set(settings.hiddenAccountIds)
            } catch {
                // Fall back to local default silently
            }
        }
    }

    // MARK: - Sync to server (debounced)
    private func syncToServer() {
        syncTask?.cancel()
        syncTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            guard !Task.isCancelled else { return }
            try? await repository.updateTheme(theme: theme.rawValue)
            try? await repository.updateHiddenAccounts(hiddenAccounts: Array(hiddenAccountIds))
        }
    }

    // MARK: - Convenience helpers
    func toggleHidden(accountId: String) {
        if hiddenAccountIds.contains(accountId) {
            hiddenAccountIds.remove(accountId)
        } else {
            hiddenAccountIds.insert(accountId)
        }
    }

    func isHidden(_ accountId: String) -> Bool {
        hiddenAccountIds.contains(accountId)
    }
}
