import SwiftUI

// MARK: - Toast View
struct ToastView: View {
    let message: ToastMessage

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(iconColor)

            Text(message.text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.AppColor.textPrimary)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.AppColor.primaryWhite)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private var iconName: String {
        switch message.style {
        case .success: return "checkmark.circle.fill"
        case .error:   return "xmark.circle.fill"
        case .info:    return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    private var iconColor: Color {
        switch message.style {
        case .success: return Color.AppColor.textSuccess
        case .error:   return Color.AppColor.textError
        case .info:    return Color.AppColor.primaryPink
        case .warning: return Color.AppColor.textWarning
        }
    }

    private var borderColor: Color {
        switch message.style {
        case .success: return Color.AppColor.textSuccess.opacity(0.3)
        case .error:   return Color.AppColor.textError.opacity(0.3)
        case .info:    return Color.AppColor.primaryPink.opacity(0.3)
        case .warning: return Color.AppColor.textWarning.opacity(0.3)
        }
    }
}

// MARK: - Toast Overlay Modifier
struct ToastOverlayModifier: ViewModifier {
    @ObservedObject private var store = ToastStore.shared

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if let message = store.current {
                ToastView(message: message)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture { store.dismiss() }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.current)
                    .zIndex(999)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.current)
    }
}

extension View {
    func withToastOverlay() -> some View {
        modifier(ToastOverlayModifier())
    }
}
