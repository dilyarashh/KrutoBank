import SwiftUI
import Combine

// MARK: - AppTheme
enum AppTheme: String, CaseIterable {
    case light
    case dark

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark:  return .dark
        }
    }

    var displayName: String {
        switch self {
        case .light: return "Светлая"
        case .dark:  return "Тёмная"
        }
    }
}

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
                theme = AppTheme(rawValue: settings.theme) ?? .light
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
            let settings = AppSettingsResponse(
                theme: theme.rawValue,
                hiddenAccountIds: Array(hiddenAccountIds)
            )
            try? await repository.saveSettings(settings)
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
