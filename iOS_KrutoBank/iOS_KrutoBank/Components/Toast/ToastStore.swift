import Foundation
import Combine

// MARK: - Toast message model
struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let style: ToastStyle
    let duration: TimeInterval

    enum ToastStyle {
        case success, error, info, warning
    }

    static func success(_ text: String, duration: TimeInterval = 2.5) -> ToastMessage {
        ToastMessage(text: text, style: .success, duration: duration)
    }

    static func error(_ text: String, duration: TimeInterval = 3.5) -> ToastMessage {
        ToastMessage(text: text, style: .error, duration: duration)
    }

    static func info(_ text: String, duration: TimeInterval = 2.5) -> ToastMessage {
        ToastMessage(text: text, style: .info, duration: duration)
    }
}

// MARK: - Global toast store
@MainActor
final class ToastStore: ObservableObject {
    static let shared = ToastStore()

    @Published var current: ToastMessage? = nil

    private var hideTask: Task<Void, Never>?

    private init() {}

    func show(_ message: ToastMessage) {
        current = message
        hideTask?.cancel()
        hideTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(message.duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            current = nil
        }
    }

    func showError(_ error: Error) {
        let appError = AppError.from(error)
        show(.error(appError.errorDescription ?? "Произошла ошибка"))
    }

    func dismiss() {
        hideTask?.cancel()
        current = nil
    }
}
